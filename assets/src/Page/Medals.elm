module Page.Medals exposing (view)

import Aisf.Scalar exposing (Id(..))
import Common
import Element exposing (..)
import Model exposing (Champion, MedalType, MedalsPageModel, Msg(..), Specialty, Year)
import RemoteData exposing (RemoteData(..))


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
                column [ spacing 5 ]
                    (champions
                        |> sortByMedals
                        |> List.map
                            (\medal ->
                                row [ spacing 15 ]
                                    [ link []
                                        { url = "/champions/" ++ Model.getId medal
                                        , label = text <| medal.name
                                        }
                                    , text <| Model.specialtyToDisplay medal.specialty
                                    ]
                            )
                    )

            _ ->
                none
        ]


sortByMedals : List Champion -> List { id : Id, name : String, medalType : MedalType, specialty : Specialty, year : Year }
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
