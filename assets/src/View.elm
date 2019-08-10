module View exposing (view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)


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
        , padding 20
        ]
    <|
        case model.currentPage of
            ListPage ->
                column [ spacing 10 ]
                    [ case model.champions of
                        Success champions ->
                            column [ spacing 5 ]
                                (List.map
                                    (\champ ->
                                        link []
                                            { url = "/champions/" ++ Model.getId champ
                                            , label = text <| champ.firstName ++ " " ++ champ.lastName
                                            }
                                    )
                                    champions
                                )

                        NotAsked ->
                            none

                        Loading ->
                            text "..."

                        _ ->
                            text "Une erreur s'est produite."
                    ]

            ChampionPage id champion ->
                column [ spacing 10 ]
                    [ link []
                        { url = "/champions"
                        , label = el [ Border.width 1 ] <| text <| "Retour à la liste"
                        }
                    , case champion of
                        Success champ ->
                            column [ spacing 5 ]
                                [ text <| Model.getId champ
                                , text <| champ.lastName
                                , text <| champ.firstName
                                ]

                        NotAsked ->
                            none

                        Loading ->
                            text "..."

                        _ ->
                            text "Une erreur s'est produite."
                    ]
