module View exposing (view)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (Document)
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Graphql.Http
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
                viewListPage model

            ChampionPage id champion ->
                viewChampionPage id champion

            NewChampionPage champion ->
                viewNewChampionPage champion


viewListPage : Model -> Element Msg
viewListPage model =
    column [ spacing 10 ]
        [ case model.champions of
            Success champions ->
                row [ spacing 20 ]
                    [ column [ spacing 5 ]
                        (List.map
                            (\champ ->
                                link []
                                    { url = "/champions/" ++ Model.getId champ
                                    , label = text <| champ.firstName ++ " " ++ champ.lastName
                                    }
                            )
                            champions
                        )
                    , link [] { url = "/champions/new", label = el [] <| text "Ajouter champion" }
                    ]

            NotAsked ->
                none

            Loading ->
                text "..."

            _ ->
                text "Une erreur s'est produite."
        ]


viewChampionPage : Id -> RemoteData (Graphql.Http.Error Champion) Champion -> Element Msg
viewChampionPage id champion =
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


viewNewChampionPage : Champion -> Element Msg
viewNewChampionPage champion =
    column []
        [ viewTextInput FirstName ]


viewTextInput : FormField -> Element Msg
viewTextInput field =
    let
        label =
            getLabelForField field
    in
    Input.text
        [ Border.solid
        , Border.rounded 8
        , paddingXY 13 7
        , Border.width 3
        ]
        { onChange = UpdatedChampionField field
        , text = ""
        , placeholder = Nothing
        , label =
            Input.labelAbove [ paddingEach { bottom = 4, right = 0, left = 0, top = 0 }, Font.bold ] <|
                paragraph [] [ text label ]
        }


getLabelForField : FormField -> String
getLabelForField field =
    case field of
        FirstName ->
            "Prénom"

        LastName ->
            "Nom"

        Email ->
            "Email"
