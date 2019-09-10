module View exposing (view)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (Document)
import Browser.Navigation as Nav
import Common
import Dict
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Graphql.Http
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Model exposing (..)
import Page.Champion
import Page.List
import Page.Medals
import Page.NewChampion
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
                Page.List.view listModel

            MedalsPage medalsModel ->
                Page.Medals.view medalsModel

            ChampionPage championModel ->
                Page.Champion.view championModel

            NewChampionPage newChampionModel ->
                Page.NewChampion.view model.currentYear newChampionModel
