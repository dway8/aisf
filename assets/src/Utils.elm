module Utils exposing (..)

import Dict exposing (Dict)
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


toDict : List a -> Dict Int a
toDict =
    List.indexedMap Tuple.pair >> Dict.fromList
