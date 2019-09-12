module Page.Medals exposing (view)

import Common
import Element exposing (..)
import Model exposing (MedalsPageModel, Msg(..))
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
                        |> List.map
                            (\champ ->
                                link []
                                    { url = "/champions/" ++ Model.getId champ
                                    , label = text <| champ.firstName ++ " " ++ champ.lastName
                                    }
                            )
                    )

            _ ->
                none
        ]
