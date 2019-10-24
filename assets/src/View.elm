module View exposing (..)

import Browser exposing (Document)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Model exposing (Model, Msg, Page(..))
import Page.Champion
import Page.Champions
import Page.EditChampion
import Page.Events
import Page.Login
import Page.Medals
import Page.Records
import Page.Teams
import RemoteData as RD
import Route exposing (Route(..))
import UI
import UI.Color as Color
import Utils


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
        column [ centerX, height fill, UI.largerSpacing, width <| px 800 ]
            [ case model.currentPage of
                EditChampionPage _ ->
                    none

                LoginPage _ ->
                    none

                _ ->
                    Utils.viewIf (model.championLoggedIn == Nothing) <| viewMenu model.currentPage
            , case model.currentPage of
                ChampionsPage championsModel ->
                    Page.Champions.view model.isAdmin model.sectors championsModel

                MedalsPage medalsModel ->
                    Page.Medals.view medalsModel

                TeamsPage teamsModel ->
                    Page.Teams.view teamsModel

                ChampionPage championModel ->
                    Page.Champion.view model.isAdmin model.championLoggedIn championModel

                EditChampionPage editChampionModel ->
                    Page.EditChampion.view model.sectors model.currentYear editChampionModel

                EventsPage eventsModel ->
                    Page.Events.view model.isAdmin eventsModel

                RecordsPage recordsModel ->
                    Page.Records.view model.isAdmin recordsModel

                LoginPage loginModel ->
                    Page.Login.view loginModel
            ]


viewMenu : Page -> Element Msg
viewMenu currentPage =
    let
        menuItem route label =
            let
                attrs =
                    (if isCurrentPage route currentPage then
                        [ Background.color <| Color.makeOpaque 0.5 Color.blue ]

                     else
                        []
                    )
                        ++ []
            in
            link
                ([ paddingXY 10 8
                 , Border.roundEach { topLeft = 3, topRight = 3, bottomLeft = 0, bottomRight = 0 }
                 , UI.fontSize 4
                 , Background.color Color.blue
                 , Font.color Color.white
                 , mouseOver [ Background.color <| Color.makeOpaque 0.5 Color.blue ]
                 ]
                    ++ attrs
                )
                { url = Route.routeToString route, label = el [] <| text label }
    in
    row [ width fill, spacing 3, Border.widthEach { bottom = 3, top = 0, right = 0, left = 0 }, Border.color <| Color.makeOpaque 0.5 Color.blue ]
        [ menuItem ChampionsRoute "Coureurs"
        , menuItem MedalsRoute "Palmarès"
        , menuItem TeamsRoute "Équipes de France"
        , menuItem EventsRoute "Lieux compétitions"
        , menuItem RecordsRoute "Records"
        ]


isCurrentPage : Route -> Page -> Bool
isCurrentPage route currentPage =
    case currentPage of
        ChampionsPage _ ->
            route == ChampionsRoute

        MedalsPage _ ->
            route == MedalsRoute

        TeamsPage _ ->
            route == TeamsRoute

        EventsPage _ ->
            route == EventsRoute

        RecordsPage _ ->
            route == RecordsRoute

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
