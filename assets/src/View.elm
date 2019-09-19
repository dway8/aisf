module View exposing (view)

import Browser exposing (Document)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Model exposing (Model, Msg, Page(..))
import Page.Admin
import Page.Champion
import Page.EditChampion
import Page.Medals
import Page.Members
import Page.Teams
import Route exposing (Route(..))
import UI
import UI.Color


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
                { name = "Open Sans"
                , url = "https://fonts.googleapis.com/css?family=Open+Sans:100,100italic,400,400italic,700"
                }
            ]
        , alignLeft
        , Font.size 16
        , padding 20
        , width fill
        , height fill
        , Font.color UI.textColor
        ]
    <|
        column [ width fill, height fill, spacing 30 ]
            [ viewMenu model.currentPage
            , case model.currentPage of
                MembersPage membersModel ->
                    Page.Members.view membersModel

                MedalsPage medalsModel ->
                    Page.Medals.view medalsModel

                TeamsPage teamsModel ->
                    Page.Teams.view teamsModel

                ChampionPage championModel ->
                    Page.Champion.view championModel

                EditChampionPage editChampionModel ->
                    Page.EditChampion.view model.currentYear editChampionModel

                AdminPage adminModel ->
                    Page.Admin.view adminModel
            ]


viewMenu : Page -> Element Msg
viewMenu currentPage =
    let
        menuItem route label =
            let
                attrs =
                    (if isCurrentPage route currentPage then
                        [ Background.color <| UI.Color.makeOpaque 0.5 UI.Color.blue ]

                     else
                        []
                    )
                        ++ []
            in
            link ([ Font.bold, UI.defaultPadding, Border.rounded 3, UI.largestFont, Background.color UI.Color.blue, Font.color UI.Color.white, mouseOver [ Background.color <| UI.Color.makeOpaque 0.5 UI.Color.blue ] ] ++ attrs) { url = Route.routeToString route, label = text label }
    in
    row [ spacing 20 ]
        [ menuItem MembersRoute "Membres AISF"
        , menuItem MedalsRoute "Palmarès"
        , menuItem TeamsRoute "Équipes de France"
        ]


isCurrentPage : Route -> Page -> Bool
isCurrentPage route currentPage =
    case currentPage of
        MembersPage _ ->
            route == MembersRoute

        MedalsPage _ ->
            route == MedalsRoute

        TeamsPage _ ->
            route == TeamsRoute

        _ ->
            False
