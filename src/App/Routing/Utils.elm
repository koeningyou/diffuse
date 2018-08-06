module Routing.Utils exposing (..)

import Dict exposing (Dict)
import Navigation
import Regex
import Response.Ext exposing (do)
import Routing.Types exposing (Msg(GoToPage), Page)
import Types as TopLevel


goTo : Page -> Cmd TopLevel.Msg
goTo page =
    page
        |> GoToPage
        |> TopLevel.RoutingMsg
        |> do


{-| Translate a `Navigation.Location` to a `Dict`,
by merging the search and hash bits.

    >>> locationToDict
    >>>     { href = ""
    >>>     , host = ""
    >>>     , hostname = ""
    >>>     , protocol = ""
    >>>     , origin = ""
    >>>     , port_ = ""
    >>>     , pathname = ""
    >>>     , search = "?a=1&b=2"
    >>>     , hash = "#c=3&d=4"
    >>>     , username = ""
    >>>     , password = ""
    >>>     }
    Dict.fromList [("a", "1"), ("b", "2"), ("c", "3"), ("d", "4")]

-}
locationToDict : Navigation.Location -> Dict String String
locationToDict location =
    let
        search =
            String.dropLeft 1 location.search

        hash =
            String.dropLeft 1 location.hash

        mapFn item =
            case String.split "=" item of
                [ a, b ] ->
                    ( a, b )

                _ ->
                    ( "in", "valid" )
    in
        [ search
        , (if String.length search > 0 && String.length hash > 0 then
            "&"
           else
            ""
          )
        , hash
        ]
            |> String.concat
            |> Regex.replace Regex.All (Regex.regex "\\?") (always "&")
            |> String.split "&"
            |> List.map mapFn
            |> Dict.fromList
