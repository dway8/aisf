module UI exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Region as Region
import Html
import Html.Attributes as HA
import Html.Events exposing (custom)
import Json.Decode as D
import UI.Button as Button
import UI.Color


smallSpacing : Attribute msg
smallSpacing =
    spacing 5


defaultSpacing : Attribute msg
defaultSpacing =
    spacing 10


largeSpacing : Attribute msg
largeSpacing =
    spacing 20


smallPadding : Attribute msg
smallPadding =
    padding 5


defaultPadding : Attribute msg
defaultPadding =
    padding 10


largePadding : Attribute msg
largePadding =
    padding 20


clickable : Attribute msg
clickable =
    htmlAttribute <| HA.style "cursor" "pointer"


notAllowedCursor : Attribute msg
notAllowedCursor =
    htmlAttribute <| HA.style "cursor" "not-allowed"


viewIcon : String -> Element msg
viewIcon icon =
    html <|
        Html.i [ HA.class <| "zmdi zmdi-" ++ icon ] []


heading : Int -> Element msg -> Element msg
heading h element =
    element
        |> el
            [ Region.heading h
            , headingSize h
            , width fill
            , height fill
            ]


fontSize : Int -> Attribute msg
fontSize int =
    case int of
        1 ->
            Font.size 12

        2 ->
            Font.size 14

        3 ->
            Font.size 16

        4 ->
            Font.size 18

        5 ->
            Font.size 22

        _ ->
            Font.size 24


headingSize : Int -> Attribute msg
headingSize h =
    (5 - h)
        |> fontSize


smallestFont : Attribute msg
smallestFont =
    fontSize 1


smallFont : Attribute msg
smallFont =
    fontSize 2


mediumFont : Attribute msg
mediumFont =
    fontSize 3


largeFont : Attribute msg
largeFont =
    fontSize 4


largestFont : Attribute msg
largestFont =
    fontSize 5


noAttr : Element.Attribute msg
noAttr =
    htmlAttribute <| HA.class ""


textColor : Color
textColor =
    rgb255 102 102 102
