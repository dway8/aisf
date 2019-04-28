module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, text)
import Http
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "AISF"
    , body =
        [ text "hey" ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { champion = NotAsked, page = ListPage }
      -- , fetchChampions
    , Cmd.none
    )



-- fetchChampions : Cmd Msg
-- fetchChampions =
--     Http.get
--         { url = "/api/champions"
--         , expect = Http.expectJson (RemoteData.fromResult >> ReceivedChampionsResponse) championsDecoder
--         }
