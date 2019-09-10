module View exposing (view)

import Browser exposing (Document)
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Model exposing (Model, Msg, Page(..))
import Page.Champion
import Page.List
import Page.Medals
import Page.NewChampion


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
        , width fill
        , height fill
        ]
    <|
        column [ width fill, height fill, spacing 30 ]
            [ viewMenu model.currentPage
            , case model.currentPage of
                ListPage listModel ->
                    Page.List.view listModel

                MedalsPage medalsModel ->
                    Page.Medals.view medalsModel

                ChampionPage championModel ->
                    Page.Champion.view championModel

                NewChampionPage newChampionModel ->
                    Page.NewChampion.view model.currentYear newChampionModel
            ]


viewMenu : Page -> Element Msg
viewMenu page =
    row [ spacing 20 ]
        [ link [ Border.width 1, padding 5 ] { url = "/champions", label = text "Liste" }
        , link [ Border.width 1, padding 5 ] { url = "/medals", label = text "Palmarès" }
        ]
