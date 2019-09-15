module Page.Medals exposing (init, view)

import Aisf.Scalar exposing (Id(..))
import Common
import Element exposing (..)
import Html
import Html.Attributes as HA
import Model exposing (Champion, MedalType, MedalsPageModel, Msg(..), Specialty, Year)
import RemoteData exposing (RemoteData(..))
import Table


init : ( MedalsPageModel, Cmd Msg )
init =
    ( { champions = Loading
      , sport = Nothing
      , specialty = Nothing
      , tableState = Table.initialSort ""
      }
    , Cmd.none
    )


view : MedalsPageModel -> Element Msg
view model =
    column [ width fill ]
        [ row [ width fill, spacing 20 ]
            [ Common.sportSelector True model.sport
            , model.sport
                |> Maybe.map (\sport -> Common.specialtySelector True (Just sport) SelectedASpecialty)
                |> Maybe.withDefault none
            ]
        , case model.champions of
            Success champions ->
                champions
                    |> sortByMedals
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el []

            _ ->
                none
        ]


type alias MedalFromChampion =
    { id : Id
    , name : String
    , medalType : MedalType
    , specialty : Specialty
    , year : Year
    }


sortByMedals : List Champion -> List MedalFromChampion
sortByMedals champions =
    champions
        |> List.foldl
            (\({ medals } as champion) acc ->
                medals
                    |> List.map
                        (\medal ->
                            { id = champion.id
                            , name = champion.firstName ++ " " ++ champion.lastName
                            , medalType = medal.medalType
                            , specialty = medal.specialty
                            , year = medal.year
                            }
                        )
                    |> (++) acc
            )
            []


tableConfig : Table.Config MedalFromChampion Msg
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


tableColumns : List (Table.Column MedalFromChampion Msg)
tableColumns =
    [ Table.veryCustomColumn
        { name = "MÉDAILLE"
        , viewData = \medal -> Common.defaultCell [] (Html.text <| Model.medalTypeToDisplay medal.medalType)
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
        , viewData = \medal -> Common.defaultCell [] (Html.text <| String.fromInt <| Model.getYear medal.year)
        , sorter = Table.decreasingOrIncreasingBy (.year >> Model.getYear)
        }
    ]
