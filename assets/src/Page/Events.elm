module Page.Events exposing (init, view)

import Api
import Common
import Dict exposing (Dict)
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as HA
import Model exposing (Competition(..), Event, Events, EventsPageModel, Msg(..), Year)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : Year -> ( EventsPageModel, Cmd Msg )
init currentYear =
    ( { events = Loading
      , tableState = Table.initialSort "ANNÉE"
      , newEvent = Nothing
      , currentYear = currentYear
      , competition = Nothing
      }
    , Api.getEvents
    )


competitionsList : List Competition
competitionsList =
    [ OlympicGames, WorldChampionships ]


view : Bool -> EventsPageModel -> Element Msg
view isAdmin model =
    column [ UI.largeSpacing, width fill ]
        [ Common.competitionSelector True competitionsList SelectedACompetition model.competition
        , Utils.viewIf (isAdmin && model.newEvent == Nothing) <|
            (row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "plus", text "Ajouter un lieu" ]
                |> Button.makeButton (Just PressedAddEventButton)
                |> Button.withBackgroundColor Color.green
                |> Button.viewButton
            )
        , Utils.viewIf isAdmin
            (model.newEvent
                |> Maybe.map (editNewEvent model.currentYear)
                |> Maybe.withDefault none
            )
        , case model.events of
            Success events ->
                events
                    |> filterByCompetition model.competition
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el [ width fill ]

            NotAsked ->
                none

            Loading ->
                UI.spinner

            _ ->
                text "Une erreur s'est produite."
        ]


filterByCompetition : Maybe Competition -> Events -> Events
filterByCompetition competition events =
    case competition of
        Nothing ->
            events

        Just c ->
            events
                |> List.filter (.competition >> (==) c)


tableConfig : Table.Config Event Msg
tableConfig =
    let
        tableCustomizations =
            Common.tableCustomizations attrsForHeaders
    in
    Table.customConfig
        { toId = .place
        , toMsg = TableMsg
        , columns = tableColumns
        , customizations = { tableCustomizations | rowAttrs = always [] }
        }


attrsForHeaders : Dict String (List (Html.Attribute msg))
attrsForHeaders =
    Dict.fromList <|
        [ ( "ANNÉE", [ HA.style "text-align" "center" ] )
        , ( "DISCIPLINE", [ HA.style "text-align" "center" ] )
        ]


tableColumns : List (Table.Column Event Msg)
tableColumns =
    [ Common.yearColumn
    , Common.competitionColumn
    , Table.veryCustomColumn
        { name = "LIEU"
        , viewData = \event -> Common.defaultCell [ HA.style "font-weight" "bold" ] (Html.text event.place)
        , sorter = Table.decreasingOrIncreasingBy .place
        }
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData =
            \event ->
                Common.centeredCell []
                    (event.sport
                        |> Maybe.map Common.sportIconHtml
                        |> Maybe.withDefault (Html.text "")
                    )
        , sorter = Table.decreasingOrIncreasingBy (.sport >> Maybe.map Model.sportToString >> Maybe.withDefault "")
        }
    ]


editNewEvent : Year -> Event -> Element Msg
editNewEvent currentYear newEvent =
    row [ UI.largeSpacing ]
        [ Common.yearSelector False currentYear SelectedAYear Nothing
        , Common.competitionSelector False competitionsList SelectedACompetition (Just newEvent.competition)
        , Utils.viewIf (newEvent.competition == WorldChampionships) <| Common.sportSelector False Nothing
        , UI.textInput []
            { onChange = UpdatedNewEventPlace
            , label = Nothing
            , text = newEvent.place
            , placeholder = Just <| Input.placeholder [ Font.italic ] <| text "Lieu"
            }
        , row [ UI.defaultSpacing ]
            [ text "Annuler"
                |> UI.smallButton (Just CancelledNewEvent)
                |> Button.withBackgroundColor Color.grey
                |> Button.viewButton
            , text "Valider"
                |> UI.smallButton (Just SaveNewEvent)
                |> Button.withBackgroundColor Color.green
                |> Button.viewButton
            ]
        ]
