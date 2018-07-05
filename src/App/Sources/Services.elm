module Sources.Services exposing (..)

{-| Service functions used in other modules.
-}

import Date exposing (Date)
import Http
import Sources.Processing.Types as Processing exposing (..)
import Sources.Types exposing (..)


-- Services

import Sources.Services.AmazonS3 as AmazonS3
import Sources.Services.AzureBlob as AzureBlob
import Sources.Services.AzureFile as AzureFile
import Sources.Services.Dropbox as Dropbox
import Sources.Services.Google as Google
import Sources.Services.Ios as Ios
import Sources.Services.Ipfs as Ipfs
import Sources.Services.Local as Local
import Sources.Services.WebDav as WebDav


-- Functions implemented by services


initialData : Service -> SourceData
initialData service =
    case service of
        AmazonS3 ->
            AmazonS3.initialData

        AzureBlob ->
            AzureBlob.initialData

        AzureFile ->
            AzureFile.initialData

        Dropbox ->
            Dropbox.initialData

        Google ->
            Google.initialData

        Ios ->
            Ios.initialData

        Ipfs ->
            Ipfs.initialData

        Local ->
            Local.initialData

        WebDav ->
            WebDav.initialData


makeTrackUrl : Service -> Date -> SourceData -> HttpMethod -> String -> String
makeTrackUrl service =
    case service of
        AmazonS3 ->
            AmazonS3.makeTrackUrl

        AzureBlob ->
            AzureBlob.makeTrackUrl

        AzureFile ->
            AzureFile.makeTrackUrl

        Dropbox ->
            Dropbox.makeTrackUrl

        Google ->
            Google.makeTrackUrl

        Ios ->
            Ios.makeTrackUrl

        Ipfs ->
            Ipfs.makeTrackUrl

        Local ->
            Local.makeTrackUrl

        WebDav ->
            WebDav.makeTrackUrl


makeTree :
    Service
    -> SourceData
    -> Marker
    -> Date
    -> (Result Http.Error String -> Processing.Msg)
    -> Cmd Processing.Msg
makeTree service =
    case service of
        AmazonS3 ->
            AmazonS3.makeTree

        AzureBlob ->
            AzureBlob.makeTree

        AzureFile ->
            AzureFile.makeTree

        Dropbox ->
            Dropbox.makeTree

        Google ->
            Google.makeTree

        Ios ->
            Ios.makeTree

        Ipfs ->
            Ipfs.makeTree

        Local ->
            Local.makeTree

        WebDav ->
            WebDav.makeTree


parseErrorResponse : Service -> String -> String
parseErrorResponse service =
    case service of
        AmazonS3 ->
            AmazonS3.parseErrorResponse

        AzureBlob ->
            AzureBlob.parseErrorResponse

        AzureFile ->
            AzureFile.parseErrorResponse

        Dropbox ->
            Dropbox.parseErrorResponse

        Google ->
            Google.parseErrorResponse

        Ios ->
            Ios.parseErrorResponse

        Ipfs ->
            Ipfs.parseErrorResponse

        Local ->
            Local.parseErrorResponse

        WebDav ->
            WebDav.parseErrorResponse


parsePreparationResponse : Service -> String -> SourceData -> Marker -> PrepationAnswer Marker
parsePreparationResponse service =
    case service of
        AmazonS3 ->
            AmazonS3.parsePreparationResponse

        AzureBlob ->
            AzureBlob.parsePreparationResponse

        AzureFile ->
            AzureFile.parsePreparationResponse

        Dropbox ->
            Dropbox.parsePreparationResponse

        Google ->
            Google.parsePreparationResponse

        Ios ->
            Ios.parsePreparationResponse

        Ipfs ->
            Ipfs.parsePreparationResponse

        Local ->
            Local.parsePreparationResponse

        WebDav ->
            WebDav.parsePreparationResponse


parseTreeResponse : Service -> String -> Marker -> TreeAnswer Marker
parseTreeResponse service =
    case service of
        AmazonS3 ->
            AmazonS3.parseTreeResponse

        AzureBlob ->
            AzureBlob.parseTreeResponse

        AzureFile ->
            AzureFile.parseTreeResponse

        Dropbox ->
            Dropbox.parseTreeResponse

        Google ->
            Google.parseTreeResponse

        Ios ->
            Ios.parseTreeResponse

        Ipfs ->
            Ipfs.parseTreeResponse

        Local ->
            Local.parseTreeResponse

        WebDav ->
            WebDav.parseTreeResponse


postProcessTree : Service -> List String -> List String
postProcessTree service =
    case service of
        AmazonS3 ->
            AmazonS3.postProcessTree

        AzureBlob ->
            AzureBlob.postProcessTree

        AzureFile ->
            AzureFile.postProcessTree

        Dropbox ->
            Dropbox.postProcessTree

        Google ->
            Google.postProcessTree

        Ios ->
            Ios.postProcessTree

        Ipfs ->
            Ipfs.postProcessTree

        Local ->
            Local.postProcessTree

        WebDav ->
            WebDav.postProcessTree


postTagsBatch : Service -> ContextForTags -> Cmd Processing.Msg
postTagsBatch service =
    case service of
        AmazonS3 ->
            AmazonS3.postTagsBatch

        AzureBlob ->
            AzureBlob.postTagsBatch

        AzureFile ->
            AzureFile.postTagsBatch

        Dropbox ->
            Dropbox.postTagsBatch

        Google ->
            Google.postTagsBatch

        Ios ->
            Ios.postTagsBatch

        Ipfs ->
            Ipfs.postTagsBatch

        Local ->
            Local.postTagsBatch

        WebDav ->
            WebDav.postTagsBatch


prepare : Service -> String -> SourceData -> Marker -> Maybe (Http.Request String)
prepare service =
    case service of
        AmazonS3 ->
            AmazonS3.prepare

        AzureBlob ->
            AzureBlob.prepare

        AzureFile ->
            AzureFile.prepare

        Dropbox ->
            Dropbox.prepare

        Google ->
            Google.prepare

        Ios ->
            Ios.prepare

        Ipfs ->
            Ipfs.prepare

        Local ->
            Local.prepare

        WebDav ->
            WebDav.prepare


properties : Service -> List ( String, String, String, Bool )
properties service =
    case service of
        AmazonS3 ->
            AmazonS3.properties

        AzureBlob ->
            AzureBlob.properties

        AzureFile ->
            AzureFile.properties

        Dropbox ->
            Dropbox.properties

        Google ->
            Google.properties

        Ios ->
            Ios.properties

        Ipfs ->
            Ipfs.properties

        Local ->
            Local.properties

        WebDav ->
            WebDav.properties



-- Utility functions


makeSource : Service -> SourceData -> Source
makeSource service data =
    { id = "change_me_please"
    , data = data
    , directoryPlaylists = True
    , enabled = True
    , service = service
    }


keyToType : String -> Service
keyToType str =
    case str of
        "AmazonS3" ->
            AmazonS3

        "AzureBlob" ->
            AzureBlob

        "AzureFile" ->
            AzureFile

        "Dropbox" ->
            Dropbox

        "Google" ->
            Google

        "Ios" ->
            Ios

        "Ipfs" ->
            Ipfs

        "Local" ->
            Local

        "WebDav" ->
            WebDav

        _ ->
            Debug.crash "Invalid Service type string"


typeToKey : Service -> String
typeToKey service =
    case service of
        AmazonS3 ->
            "AmazonS3"

        AzureBlob ->
            "AzureBlob"

        AzureFile ->
            "AzureFile"

        Dropbox ->
            "Dropbox"

        Google ->
            "Google"

        Ios ->
            "Ios"

        Ipfs ->
            "Ipfs"

        Local ->
            "Local"

        WebDav ->
            "WebDav"


{-| Service labels.

Maps a service key to a label.

-}
labels : ViabilityDependencies -> List ( String, String )
labels { isElectron, isIOS } =
    let
        default =
            [ ( typeToKey AmazonS3, "Amazon S3" )
            , ( typeToKey AzureBlob, "Azure Blob Storage" )
            , ( typeToKey AzureFile, "Azure File Storage" )
            , ( typeToKey Dropbox, "Dropbox" )
            , ( typeToKey Google, "Google Drive" )
            , ( typeToKey Ipfs, "IPFS" )
            ]
    in
        if isElectron then
            List.append
                default
                [ ( typeToKey Local, "This Computer" )
                , ( typeToKey WebDav, "WebDAV" )
                ]
        else if isIOS then
            List.append
                default
                [ ( typeToKey Ios, "This iOS Device" )
                ]
        else
            default


{-| Build a `NewForm` from a redirect with a hash.
Example use-case: OAuth
-}
newFormThroughRedirect : Service -> String -> Form
newFormThroughRedirect service hash =
    case service of
        Dropbox ->
            NewForm 3 (makeSource Dropbox <| Dropbox.authorizationSourceData hash)

        Google ->
            NewForm 3 (makeSource Google <| Google.authorizationSourceData hash)

        _ ->
            NewForm 3 (makeSource service <| initialData service)
