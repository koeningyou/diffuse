module UI.Core exposing (Flags, Model, Msg(..), Switch(..))

import Alien
import Authentication
import Browser
import Browser.Navigation as Nav
import Json.Encode as Json
import UI.Backdrop
import UI.Page exposing (Page)
import UI.Sources
import Url exposing (Url)



-- ⛩


type alias Flags =
    {}



-- 🌳


type alias Model =
    { isAuthenticated : Bool
    , isLoading : Bool
    , navKey : Nav.Key
    , page : Page
    , url : Url

    -----------------------------------------
    -- Children
    -----------------------------------------
    , backdrop : UI.Backdrop.Model
    , sources : UI.Sources.Model
    }



-- 📣


type Msg
    = Bypass
    | LoadEnclosedUserData Json.Value
    | LoadHypaethralUserData Json.Value
    | ToggleLoadingScreen Switch
      -----------------------------------------
      -- Children
      -----------------------------------------
    | BackdropMsg UI.Backdrop.Msg
    | SourcesMsg UI.Sources.Msg
      -----------------------------------------
      -- Brain
      -----------------------------------------
    | NotifyBrain Alien.Event
    | ProcessSources
    | SaveEnclosedUserData
    | SaveHypaethralUserData
    | SignIn Authentication.Method
    | SignOut
      -----------------------------------------
      -- URL
      -----------------------------------------
    | ChangeUrlUsingPage Page
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url


type Switch
    = On
    | Off
