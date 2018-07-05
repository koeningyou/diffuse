module Sources.Services.Ios exposing (..)

{-| Local Service.

For those local files out there.

-}

import Date exposing (Date)
import Dict
import Dict.Ext as Dict
import Http
import Json.Decode
import Json.Encode
import Slave.Events exposing (..)
import Sources.Pick
import Sources.Processing.Types exposing (..)
import Sources.Services.Utils exposing (noPrep)
import Sources.Types exposing (SourceData)
import String.Ext as String
import Time
import Utils exposing (encodeUri)


serverUrl : String
serverUrl =
    "http://127.0.0.1:44999"



-- Properties
-- 📟


defaults =
    { name = "Music from iOS device"
    }


{-| The list of properties we need from the user.

Tuple: (property, label, placeholder, isPassword)
Will be used for the forms.

-}
properties : List ( String, String, String, Bool )
properties =
    [ ( "name", "Label", defaults.name, False )
    ]


{-| Initial data set.
-}
initialData : SourceData
initialData =
    Dict.fromList
        [ ( "name", defaults.name )
        ]



-- Preparation


prepare : String -> SourceData -> Marker -> Maybe (Http.Request String)
prepare _ _ _ =
    Nothing



-- Tree


{-| Create a directory tree.

List all the tracks in the bucket.
Or a specific directory in the bucket.

-}
makeTree : SourceData -> Marker -> Date -> (Result Http.Error String -> Msg) -> Cmd Msg
makeTree srcData marker currentDate resultMsg =
    (serverUrl ++ "/lib/tree")
        |> Http.getString
        |> Http.send resultMsg


{-| Re-export parser functions.
-}
parsePreparationResponse : String -> SourceData -> Marker -> PrepationAnswer Marker
parsePreparationResponse =
    noPrep


parseTreeResponse : String -> Marker -> TreeAnswer Marker
parseTreeResponse response _ =
    let
        paths =
            response
                |> Json.Decode.decodeString (Json.Decode.list Json.Decode.string)
                |> Result.withDefault []
    in
        { filePaths = paths
        , marker = TheEnd
        }


parseErrorResponse : String -> String
parseErrorResponse =
    identity



-- Post


{-| Post process the tree results.

!!! Make sure we only use music files that we can use.

-}
postProcessTree : List String -> List String
postProcessTree =
    identity


{-| Command to be executed after each tags step.
-}
postTagsBatch : ContextForTags -> Cmd Msg
postTagsBatch _ =
    (serverUrl ++ "/lib/flush")
        |> Http.getString
        |> Http.send (always NoOp)



-- Track URL


{-| Create a public url for a file.

We need this to play the track.

-}
makeTrackUrl : Date -> SourceData -> HttpMethod -> String -> String
makeTrackUrl currentDate srcData method pathToFile =
    serverUrl ++ "/lib/file?path=" ++ encodeUri pathToFile
