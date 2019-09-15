module Utils exposing (capitalize, viewIf)

import Element exposing (..)


capitalize : String -> String
capitalize string =
    case String.uncons string of
        Just ( firstLetter, rest ) ->
            String.cons (Char.toUpper firstLetter) rest

        Nothing ->
            ""


viewIf : Bool -> Element msg -> Element msg
viewIf condition elem =
    if condition then
        elem

    else
        none
