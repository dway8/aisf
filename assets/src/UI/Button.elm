module UI.Button exposing (makeButton, viewButton, withAlpha, withAttrs, withBackgroundColor, withBorderColor, withBorderWidth, withCursor, withDisabled, withFontColor, withPadding, withRounded)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import UI.Color


type ButtonTemplate msg
    = ButtonTemplate (ButtonInternal msg)


type alias ButtonInternal msg =
    { msg : Maybe msg
    , label : Element msg
    , padding : Attribute msg
    , rounded : Attribute msg
    , cursor : Attribute msg
    , disabled : Bool
    , fontColor : Color
    , backgroundColor : Color
    , borderColor : Color
    , borderWidth : Attribute msg
    , alpha : Float
    , attrs : List (Attribute msg)
    }


makeButton : Maybe msg -> Element msg -> ButtonTemplate msg
makeButton maybeMsg elem =
    ButtonTemplate
        { msg = maybeMsg
        , label = elem
        , padding = padding 10
        , rounded = Border.rounded 3
        , cursor = pointer
        , disabled = False
        , fontColor = UI.Color.white
        , backgroundColor = rgba 0 0 0 0
        , borderColor = rgba 0 0 0 0
        , borderWidth = Border.width 1
        , alpha = 1
        , attrs = []
        }


map : (ButtonInternal msg -> ButtonInternal msg) -> ButtonTemplate msg -> ButtonTemplate msg
map fn template =
    case template of
        ButtonTemplate button ->
            ButtonTemplate <| fn button


withPadding : Attribute msg -> ButtonTemplate msg -> ButtonTemplate msg
withPadding padding template =
    template |> map (\bi -> { bi | padding = padding })


withRounded : Attribute msg -> ButtonTemplate msg -> ButtonTemplate msg
withRounded rounded template =
    template |> map (\bi -> { bi | rounded = rounded })


withCursor : Attribute msg -> ButtonTemplate msg -> ButtonTemplate msg
withCursor cursor template =
    template |> map (\bi -> { bi | cursor = cursor })


withDisabled : Bool -> ButtonTemplate msg -> ButtonTemplate msg
withDisabled disabled template =
    template |> map (\bi -> { bi | disabled = disabled })


withFontColor : Color -> ButtonTemplate msg -> ButtonTemplate msg
withFontColor color template =
    template |> map (\bi -> { bi | fontColor = color })


withBackgroundColor : Color -> ButtonTemplate msg -> ButtonTemplate msg
withBackgroundColor color template =
    template |> map (\bi -> { bi | backgroundColor = color })


withBorderColor : Color -> ButtonTemplate msg -> ButtonTemplate msg
withBorderColor color template =
    template |> map (\bi -> { bi | borderColor = color })


withBorderWidth : Attribute msg -> ButtonTemplate msg -> ButtonTemplate msg
withBorderWidth w template =
    template |> map (\bi -> { bi | borderWidth = w })


withAlpha : Float -> ButtonTemplate msg -> ButtonTemplate msg
withAlpha alphaValue template =
    template |> map (\bi -> { bi | alpha = alphaValue })


withAttrs : List (Attribute msg) -> ButtonTemplate msg -> ButtonTemplate msg
withAttrs attrs template =
    template |> map (\bi -> { bi | attrs = attrs })


viewButton : ButtonTemplate msg -> Element msg
viewButton buttonTemplate =
    case buttonTemplate of
        ButtonTemplate button ->
            Input.button
                ([ button.padding
                 , button.rounded
                 , button.cursor
                 , htmlAttribute <| HA.disabled <| button.disabled
                 , Font.color button.fontColor
                 , Background.color <| button.backgroundColor
                 , Border.color <| button.borderColor
                 , button.borderWidth
                 , alpha button.alpha
                 , Font.bold
                 , mouseOver [ Background.color <| UI.Color.makeDarker button.backgroundColor ]
                 ]
                    ++ button.attrs
                )
                { label = button.label
                , onPress = button.msg
                }
