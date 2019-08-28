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
            ListPage listModel ->
                viewListPage listModel

            ChampionPage championModel ->
                viewChampionPage championModel

            NewChampionPage champion ->
                viewNewChampionPage champion


viewListPage : ListPageModel -> Element Msg
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


viewChampionPage : ChampionPageModel -> Element Msg
viewChampionPage { id, champion } =
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
                    , champ.sport |> Maybe.map (Model.sportToString >> text) |> Maybe.withDefault none
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
        [ viewTextInput FirstName champion
        , viewTextInput LastName champion
        , viewTextInput Email champion
        , Input.button [] { onPress = Just PressedSaveChampionButton, label = text "Enregistrer" }
        ]


viewTextInput : FormField -> Champion -> Element Msg
viewTextInput field champion =
    let
        ( label, value ) =
            getLabelAndValueForField field champion
    in
    Input.text
        [ Border.solid
        , Border.rounded 8
        , paddingXY 13 7
        , Border.width 3
        ]
        { onChange = UpdatedChampionField field
        , text = value
        , placeholder = Nothing
        , label =
            Input.labelAbove [ paddingEach { bottom = 4, right = 0, left = 0, top = 0 }, Font.bold ] <|
                paragraph [] [ text label ]
        }


getLabelAndValueForField : FormField -> Champion -> ( String, String )
getLabelAndValueForField field champion =
    case field of
        FirstName ->
            ( "Prénom", champion.firstName )

        LastName ->
            ( "Nom", champion.lastName )

        Email ->
            ( "Email", champion.email )
