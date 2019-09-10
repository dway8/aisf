module Page.Medals exposing (view)

import Common
import Element exposing (..)
import Model exposing (MedalsPageModel, Msg(..))


view : MedalsPageModel -> Element Msg
view model =
    column [ width fill ]
        [ row [ width fill, spacing 20 ]
            [ Common.sportSelector True model.sport
            , model.sport
                |> Maybe.map (\sport -> Common.specialtySelector True (Just sport) SelectedASpecialty)
                |> Maybe.withDefault none
            ]
        ]
