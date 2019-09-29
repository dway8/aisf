module UI.Color exposing (..)

import Element exposing (Color, rgb255, rgba, toRgb)


white : Color
white =
    rgb255 255 255 255


black : Color
black =
    rgb255 17 17 17


lightestGrey : Color
lightestGrey =
    rgb255 244 244 244


lighterGrey : Color
lighterGrey =
    rgb255 230 230 230


lightGrey : Color
lightGrey =
    rgb255 187 187 187


grey : Color
grey =
    rgb255 178 178 178


darkGrey : Color
darkGrey =
    rgb255 136 136 136


darkerGrey : Color
darkerGrey =
    rgb255 101 101 101


darkestGrey : Color
darkestGrey =
    rgb255 82 82 82


red : Color
red =
    rgb255 247 22 53


green : Color
green =
    rgb255 39 203 139


blue : Color
blue =
    rgb255 2 81 184


lightBlue : Color
lightBlue =
    rgb255 127 219 255


darkBlue : Color
darkBlue =
    rgb255 0 31 63


orange : Color
orange =
    rgb255 255 157 0


yellow : Color
yellow =
    rgb255 255 226 0


makeOpaque : Float -> Color -> Color
makeOpaque opacity color =
    let
        rgb =
            toRgb color
    in
    rgba rgb.red rgb.green rgb.blue opacity


makeDarker : Color -> Color
makeDarker color =
    let
        rgb =
            toRgb color

        darkerRed =
            rgb.red * 0.8

        darkerGreen =
            rgb.green * 0.8

        darkerBlue =
            rgb.blue * 0.8
    in
    rgba darkerRed darkerGreen darkerBlue rgb.alpha


colorToRgbList : Color -> List String
colorToRgbList color =
    color
        |> toRgb
        |> (\v -> [ v.red, v.green, v.blue, v.alpha ])
        |> List.map ((*) 255 >> round >> String.fromInt)


colorToString : Color -> String
colorToString color =
    colorToRgbList color
        |> String.join ","
        |> (\str -> "rgba(" ++ str ++ ")")
