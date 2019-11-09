module Page.Teams exposing (init, view)

import Aisf.Scalar exposing (Id(..))
import Common
import Dict exposing (Dict)
import Element exposing (..)
import Element.Keyed as EK
import Element.Lazy as EL
import Graphql.Http
import Html
import Html.Attributes as HA
import Model exposing (Champions, Msg(..), Sport, TeamsPageModel, Year)
import RemoteData exposing (RemoteData(..))
import Table
import UI


init : Year -> ( TeamsPageModel, Cmd Msg )
init year =
    ( { sport = Nothing
      , tableState = Table.initialSort "ANNÉE"
      , currentYear = year
      , selectedYear = Nothing
      , searchQuery = Nothing
      }
    , Cmd.none
    )


view : RemoteData (Graphql.Http.Error Champions) Champions -> TeamsPageModel -> Element Msg
view rdChampions model =
    EK.el [ width fill ] <|
        ( "teams-page"
        , column [ UI.largeSpacing, width fill ]
            [ row [ UI.largeSpacing ]
                [ Common.viewSearchQuery model.searchQuery
                , Common.sportSelector True model.sport
                , Common.yearSelector True model.currentYear SelectedAYear Nothing
                ]
            , case rdChampions of
                Success champions ->
                    EL.lazy5 viewChampionsTable model.searchQuery model.sport model.selectedYear model.tableState champions

                Loading ->
                    UI.spinner

                _ ->
                    none
            ]
        )


viewChampionsTable : Maybe String -> Maybe Sport -> Maybe Year -> Table.State -> Champions -> Element Msg
viewChampionsTable searchQuery sport selectedYear tableState champions =
    champions
        |> Common.filterBySearchQuery searchQuery
        |> getYearsInTeamsFromChampions
        |> filterBySport sport
        |> filterByYear selectedYear
        |> Table.view tableConfig tableState
        |> html
        |> el [ htmlAttribute <| HA.id "teams-list", width fill ]


type alias YearInTeamFromChampion =
    { id : Id
    , name : String
    , sport : Sport
    , year : Year
    , isMember : Bool
    }


getYearsInTeamsFromChampions : Champions -> List YearInTeamFromChampion
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
                            , isMember = champion.isMember
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
            Common.tableCustomizations attrsForHeaders
    in
    Table.customConfig
        { toId = Model.getId
        , toMsg = TableMsg
        , columns = tableColumns
        , customizations = { tableCustomizations | rowAttrs = Common.toRowAttrs }
        }


attrsForHeaders : Dict String (List (Html.Attribute msg))
attrsForHeaders =
    Dict.fromList <|
        [ ( "MEMBRE", [ HA.style "text-align" "center" ] )
        , ( "ANNÉE", [ HA.style "text-align" "center" ] )
        , ( "DISCIPLINE", [ HA.style "text-align" "center" ] )
        ]


tableColumns : List (Table.Column YearInTeamFromChampion Msg)
tableColumns =
    [ Common.memberColumn
    , Table.veryCustomColumn
        { name = "NOM / PRÉNOM"
        , viewData = \champion -> Common.defaultCell [] (Html.text <| champion.name)
        , sorter = Table.decreasingOrIncreasingBy .name
        }
    , Common.sportColumn
    , Table.veryCustomColumn
        { name = "ANNÉE"
        , viewData = \champion -> Common.centeredCell [] (Html.text <| String.fromInt <| Model.getYear champion.year)
        , sorter = Table.decreasingOrIncreasingBy (.year >> Model.getYear)
        }
    ]
