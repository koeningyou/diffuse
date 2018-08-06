module Sources.Services.OneDrive exposing (..)

{-| Dropbox Service.
-}

import Base64
import Date exposing (Date)
import Dict exposing (Dict)
import Dict.Ext as Dict
import Http
import Json.Decode
import Json.Encode
import Regex
import Sources.Pick
import Sources.Processing.Types exposing (..)
import Sources.Services.OneDrive.Parser as Parser
import Sources.Services.Utils exposing (cleanPath, noPrep)
import Sources.Types exposing (SourceData)
import Time
import Utils exposing (encodeUri, makeQueryParam)


-- Properties
-- 📟


defaults =
    { clientId = "363b2c44-66a1-49c2-bef0-df7553b0796c"
    , clientSecret = "puylWECF8^fnwRJF4650}}*"
    , directoryPath = "/"
    , name = "Music from One Drive"
    }


{-| The list of properties we need from the user.

Tuple: (property, label, placeholder, isPassword)
Will be used for the forms.

-}
properties : List ( String, String, String, Bool )
properties =
    [ ( "authCode", "Auth Code", "...", True )
    , ( "clientId", "Client Id (App Portal)", defaults.clientId, False )
    , ( "clientSecret", "Client Secret (App Portal)", defaults.clientSecret, False )
    , ( "directoryPath", "Directory", defaults.directoryPath, False )
    , ( "name", "Label", defaults.name, False )
    ]


{-| Initial data set.
-}
initialData : SourceData
initialData =
    Dict.fromList
        [ ( "authCode", "" )
        , ( "clientId", defaults.clientId )
        , ( "clientSecret", defaults.clientSecret )
        , ( "directoryPath", defaults.directoryPath )
        , ( "name", defaults.name )
        ]



-- Authorization Procedure


{-| Authorization url.
-}
authorizationUrl : String -> SourceData -> String
authorizationUrl origin sourceData =
    let
        encodeData data =
            data
                |> Dict.toList
                |> List.map (Tuple.mapSecond Json.Encode.string)
                |> Json.Encode.object

        state =
            sourceData
                |> encodeData
                |> Json.Encode.encode 0
                |> Base64.encode
    in
        [ ( "client_id", Dict.fetch "clientId" "unknown" sourceData )
        , ( "redirect_uri", origin ++ "/sources/new/onedrive#state=" ++ encodeUri state )
        , ( "response_type", "code" )
        , ( "scope", "files.read offline_access" )
        ]
            |> List.map makeQueryParam
            |> String.join "&"
            |> String.append "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?"


{-| Authorization source data.
-}
authorizationSourceData : Dict String String -> SourceData
authorizationSourceData dict =
    dict
        |> Dict.get "state"
        |> Maybe.andThen Http.decodeUri
        |> Maybe.andThen (Base64.decode >> Result.toMaybe)
        |> Maybe.withDefault "{}"
        |> Json.Decode.decodeString (Json.Decode.dict Json.Decode.string)
        |> Result.withDefault Dict.empty
        |> Dict.unionF initialData
        |> Dict.update "authCode" (always <| Dict.get "code" dict)



-- Preparation


{-| Before processing we need to prepare the source.
In this case this means that we will refresh the `access_token`.
Or if we don't have an access token yet, get one.
-}
prepare : String -> SourceData -> Marker -> Maybe (Http.Request String)
prepare origin srcData _ =
    let
        maybeCode =
            Dict.get "authCode" srcData

        params =
            case maybeCode of
                -- Exchange authorization code for access token & request token
                Just authCode ->
                    [ ( "client_id", Dict.fetch "clientId" "" srcData )
                    , ( "client_secret", Dict.fetch "clientSecret" "" srcData )
                    , ( "code", Dict.fetch "authCode" "" srcData )
                    , ( "grant_type", "authorization_code" )
                    , ( "redirect_uri", origin ++ "/sources/new/onedrive" )
                    ]

                -- Refresh access token
                Nothing ->
                    [ ( "client_id", Dict.fetch "clientId" "" srcData )
                    , ( "client_secret", Dict.fetch "clientSecret" "" srcData )
                    , ( "refresh_token", Dict.fetch "refreshToken" "" srcData )
                    , ( "grant_type", "refresh_token" )
                    ]

        cgiParams =
            params
                |> List.map makeQueryParam
                |> String.join "&"

        url =
            "https://login.microsoftonline.com/common/oauth2/v2.0/token"
    in
        { method = "POST"
        , headers = []
        , url = url
        , body = Http.stringBody "application/x-www-form-urlencoded" cgiParams
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }
            |> Http.request
            |> Just



-- Tree


{-| Create a directory tree.

List all the tracks in the bucket.
Or a specific directory in the bucket.

-}
makeTree : SourceData -> Marker -> Date -> (Result Http.Error String -> Msg) -> Cmd Msg
makeTree srcData marker currentDate resultMsg =
    let
        accessToken =
            Dict.fetch "accessToken" "" srcData
    in
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , url = "https://graph.microsoft.com/v1.0/me/drive/root/children"
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }
            |> Http.request
            |> Http.send resultMsg


{-| Re-export parser functions.
-}
parsePreparationResponse : String -> SourceData -> Marker -> PrepationAnswer Marker
parsePreparationResponse =
    Parser.parsePreparationResponse


parseTreeResponse : String -> Marker -> TreeAnswer Marker
parseTreeResponse =
    Parser.parseTreeResponse


parseErrorResponse : String -> String
parseErrorResponse =
    Parser.parseErrorResponse



-- Post


{-| Post process the tree results.

!!! Make sure we only use music files that we can use.

-}
postProcessTree : List String -> List String
postProcessTree =
    Sources.Pick.selectMusicFiles



-- Track URL


{-| Create a public url for a file.

We need this to play the track.

-}
makeTrackUrl : Date -> SourceData -> HttpMethod -> String -> String
makeTrackUrl currentDate srcData method pathToFile =
    "dropbox://" ++ Dict.fetch "accessToken" "" srcData ++ "@" ++ pathToFile
