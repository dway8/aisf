module Main exposing (main)

import Api
import Browser exposing (Document)
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Font as Font
import Html exposing (Html)
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
    case msg of
        GotChampions resp ->
            ( { model | champions = resp }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "AISF"
    , body =
        [ viewBody model ]
    }


viewBody : Model -> Html Msg
viewBody model =
    layout
        [ Font.family
            [ Font.external
                { name = "Roboto"
                , url = "https://fonts.googleapis.com/css?family=Roboto:100,200,200italic,300,300italic,400,400italic,600,700,800"
                }
            ]
        , alignLeft
        , Font.size 16
        ]
    <|
        column [ spacing 10 ]
            [ case model.champions of
                Success champions ->
                    column [ spacing 5 ]
                        (List.map
                            (\champ -> text <| champ.firstName ++ " " ++ champ.lastName)
                            champions
                        )

                NotAsked ->
                    none

                Loading ->
                    text "..."

                _ ->
                    text "Une erreur s'est produite."
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { champions = NotAsked, page = ListPage }
    , Api.getChampions
    )
