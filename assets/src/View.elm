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
import Page.Events
import Page.Medals
import Page.Members
import Page.Teams
import RemoteData as RD
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
    UI.defaultLayout
        ([ Font.family
            [ Font.typeface "Open Sans", Font.typeface "Roboto", Font.typeface "Arial" ]
         , alignLeft
         , UI.mediumFont
         , UI.largePadding
         , width fill
         , Font.color UI.textColor
         ]
            ++ viewDialogs model
        )
    <|
        column [ width fill, spacing 30 ]
            [ case model.currentPage of
                EditChampionPage _ ->
                    none

                _ ->
                    viewMenu model.currentPage
            , case model.currentPage of
                MembersPage membersModel ->
                    Page.Members.view membersModel

                MedalsPage medalsModel ->
                    Page.Medals.view medalsModel

                TeamsPage teamsModel ->
                    Page.Teams.view teamsModel

                ChampionPage championModel ->
                    Page.Champion.view model.isAdmin championModel

                EditChampionPage editChampionModel ->
                    Page.EditChampion.view model.sectors model.currentYear editChampionModel

                AdminPage adminModel ->
                    Page.Admin.view model.sectors adminModel

                EventsPage eventsModel ->
                    Page.Events.view model.isAdmin eventsModel
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
        , menuItem EventsRoute "Lieux des compétitions"
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

        EventsPage _ ->
            route == EventsRoute

        _ ->
            False


viewDialogs : Model -> List (Attribute Msg)
viewDialogs model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\{ pictures, id } ->
                        case cModel.pictureDialog of
                            Just picture ->
                                [ inFront <| Page.Champion.viewPictureDialog id picture pictures ]

                            _ ->
                                []
                    )
                |> RD.withDefault []

        _ ->
            []
