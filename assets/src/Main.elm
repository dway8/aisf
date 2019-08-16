module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Http
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Update
import Url exposing (Url)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = Update.update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( page, cmd ) =
            Update.parseUrl url
                |> Update.getPageAndCmdFromRoute
    in
    ( { currentPage = page
      , key = key
      , isAdmin = flags.isAdmin
      }
    , cmd
    )
