module Page.Medals exposing (init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Dict exposing (Dict)
import Element exposing (..)
import Html
import Html.Attributes as HA
import Model exposing (Champion, Competition, MedalType, MedalsPageModel, Msg(..), Specialty, Sport, Year)
import RemoteData exposing (RemoteData(..))
import Table
import UI


init : Year -> ( MedalsPageModel, Cmd Msg )
init year =
    ( { champions = Loading
      , sport = Nothing
      , specialty = Nothing
      , tableState = Table.initialSort "ANNÉE"
      , currentYear = year
      , selectedYear = Nothing
      , searchQuery = Nothing
      }
    , Api.getChampionsWithMedals
    )


view : MedalsPageModel -> Element Msg
view model =
    column [ UI.largeSpacing, width fill ]
        [ row [ UI.largeSpacing ]
            [ Common.viewSearchQuery model.searchQuery
            , Common.sportSelector True model.sport
            , model.sport
                |> Maybe.map (\sport -> Common.specialtySelector True (Just sport) SelectedASpecialty Nothing)
                |> Maybe.withDefault none
            , Common.yearSelector True model.currentYear SelectedAYear Nothing
            ]
        , case model.champions of
            Success champions ->
                champions
                    |> Common.filterBySearchQuery model.searchQuery
                    |> getMedalsFromChampions
                    |> filterBySportAndSpecialty model.sport model.specialty
                    |> filterByYear model.selectedYear
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el [ htmlAttribute <| HA.id "medals-list", width fill ]

            Loading ->
                UI.spinner

            _ ->
                none
        ]


type alias MedalFromChampion =
    { id : Id
    , name : String
    , competition : Competition
    , medalType : MedalType
    , sport : Sport
    , specialty : Specialty
    , year : Year
    }


getMedalsFromChampions : List Champion -> List MedalFromChampion
getMedalsFromChampions champions =
    champions
        |> List.foldl
            (\({ medals } as champion) acc ->
                medals
                    |> List.map
                        (\medal ->
                            { id = champion.id
                            , name = Model.getName champion
                            , competition = medal.competition
                            , medalType = medal.medalType
                            , sport = champion.sport
                            , specialty = medal.specialty
                            , year = medal.year
                            }
                        )
                    |> (++) acc
            )
            []


filterBySportAndSpecialty : Maybe Sport -> Maybe Specialty -> List MedalFromChampion -> List MedalFromChampion
filterBySportAndSpecialty sport specialty medals =
    case ( sport, specialty ) of
        ( Nothing, _ ) ->
            medals

        ( Just s, maybeSpecialty ) ->
            medals
                |> List.filter (.sport >> (==) s)
                |> (\list -> maybeSpecialty |> Maybe.map (\spe -> list |> List.filter (.specialty >> (==) spe)) |> Maybe.withDefault list)


filterByYear : Maybe Year -> List MedalFromChampion -> List MedalFromChampion
filterByYear year medals =
    case year of
        Nothing ->
            medals

        Just y ->
            medals
                |> List.filter (.year >> (==) y)


tableConfig : Table.Config MedalFromChampion Msg
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
        [ ( "MÉDAILLE", [ HA.style "text-align" "center" ] )
        , ( "ANNÉE", [ HA.style "text-align" "center" ] )
        ]


tableColumns : List (Table.Column MedalFromChampion Msg)
tableColumns =
    [ Table.veryCustomColumn
        { name = "MÉDAILLE"
        , viewData =
            \medal -> Common.centeredCell [] (Common.medalIconHtml medal)
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "NOM / PRÉNOM"
        , viewData = \medal -> Common.defaultCell [] (Html.text <| medal.name)
        , sorter = Table.decreasingOrIncreasingBy .name
        }
    , Table.veryCustomColumn
        { name = "SPÉCIALITÉ"
        , viewData = \medal -> Common.defaultCell [] (Html.text <| Model.specialtyToDisplay medal.specialty)
        , sorter = Table.decreasingOrIncreasingBy (.specialty >> Model.specialtyToDisplay)
        }
    , Table.veryCustomColumn
        { name = "ANNÉE"
        , viewData = \medal -> Common.centeredCell [] (Html.text <| String.fromInt <| Model.getYear medal.year)
        , sorter = Table.decreasingOrIncreasingBy (.year >> Model.getYear)
        }
    ]
