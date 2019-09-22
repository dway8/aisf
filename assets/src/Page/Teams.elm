module Page.Teams exposing (init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Element exposing (..)
import Html
import Html.Attributes as HA
import Model exposing (Champion, Msg(..), Sport, TeamsPageModel, Year)
import RemoteData exposing (RemoteData(..))
import Table
import UI


init : Year -> ( TeamsPageModel, Cmd Msg )
init year =
    ( { champions = Loading
      , sport = Nothing
      , tableState = Table.initialSort ""
      , currentYear = year
      , selectedYear = Nothing
      , searchQuery = Nothing
      }
    , Api.getChampions
    )


view : TeamsPageModel -> Element Msg
view model =
    column [ width fill, UI.defaultSpacing ]
        [ row [ width fill, UI.defaultSpacing ]
            [ Common.viewSearchQuery model.searchQuery
            , Common.sportSelector True model.sport
            , Common.yearSelector True model.currentYear SelectedAYear
            ]
        , case model.champions of
            Success champions ->
                champions
                    |> Common.filterBySearchQuery model.searchQuery
                    |> getYearsInTeamsFromChampions
                    |> filterBySport model.sport
                    |> filterByYear model.selectedYear
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el [ htmlAttribute <| HA.id "teams-list" ]

            _ ->
                none
        ]


type alias YearInTeamFromChampion =
    { id : Id
    , name : String
    , sport : Sport
    , year : Year
    }


getYearsInTeamsFromChampions : List Champion -> List YearInTeamFromChampion
getYearsInTeamsFromChampions champions =
    champions
        |> List.foldl
            (\({ yearsInFrenchTeam } as champion) acc ->
                yearsInFrenchTeam
                    |> List.map
                        (\year ->
                            { id = champion.id
                            , name = Model.getName champion
                            , sport = champion.sport
                            , year = year
                            }
                        )
                    |> (++) acc
            )
            []


filterBySport : Maybe Sport -> List YearInTeamFromChampion -> List YearInTeamFromChampion
filterBySport sport champions =
    case sport of
        Nothing ->
            champions

        Just s ->
            champions
                |> List.filter (.sport >> (==) s)


filterByYear : Maybe Year -> List YearInTeamFromChampion -> List YearInTeamFromChampion
filterByYear year champions =
    case year of
        Nothing ->
            champions

        Just y ->
            champions
                |> List.filter (.year >> (==) y)


tableConfig : Table.Config YearInTeamFromChampion Msg
tableConfig =
    let
        tableCustomizations =
            Common.tableCustomizations
    in
    Table.customConfig
        { toId = Model.getId
        , toMsg = TableMsg
        , columns = tableColumns
        , customizations = { tableCustomizations | rowAttrs = Common.toRowAttrs }
        }


tableColumns : List (Table.Column YearInTeamFromChampion Msg)
tableColumns =
    [ Table.veryCustomColumn
        { name = "NOM / PRÉNOM"
        , viewData = \champion -> Common.defaultCell [] (Html.text <| champion.name)
        , sorter = Table.decreasingOrIncreasingBy .name
        }
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData = \champion -> Common.defaultCell [] (Html.text <| Model.sportToString champion.sport)
        , sorter = Table.decreasingOrIncreasingBy (.sport >> Model.sportToString)
        }
    , Table.veryCustomColumn
        { name = "ANNÉE"
        , viewData = \champion -> Common.defaultCell [] (Html.text <| String.fromInt <| Model.getYear champion.year)
        , sorter = Table.decreasingOrIncreasingBy (.year >> Model.getYear)
        }
    ]
