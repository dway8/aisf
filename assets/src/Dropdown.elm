module Dropdown exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Menu
import UI exposing (..)
import UI.Color as Color
import Utils


type alias Model =
    { query : Maybe String
    , selected : List String
    , showMenu : Bool
    , state : Menu.State
    }


init : Model
init =
    { query = Nothing
    , selected = []
    , showMenu = False
    , state = Menu.empty
    }


setState : Menu.State -> Model -> Model
setState state model =
    { model | state = state }


setQuery : Maybe String -> Model -> Model
setQuery query model =
    { model | query = query }


isQueryEmpty : Model -> Bool
isQueryEmpty model =
    model.query |> Maybe.withDefault "" |> String.isEmpty


toggleMenu : Bool -> Model -> Model
toggleMenu showMenu model =
    { model | showMenu = showMenu }


setSelected : List String -> Model -> Model
setSelected list model =
    { model | selected = list }


addSelected : String -> Model -> Model
addSelected data model =
    { model | selected = model.selected ++ [ data ] }


removeSelected : String -> Model -> Model
removeSelected str model =
    let
        selected =
            model.selected |> List.filter ((/=) str)
    in
    { model | selected = selected }


emptyState : Model -> Model
emptyState model =
    { model | state = Menu.empty }


updateConfig : (String -> msg) -> msg -> msg -> Menu.UpdateConfig msg String
updateConfig selectMsg createMsg resetMsg =
    Menu.updateConfig
        { toId = identity
        , onKeyDown =
            \code maybeId ->
                if code == 38 || code == 40 then
                    Nothing

                else if code == 13 then
                    case maybeId of
                        Just id ->
                            Just <| selectMsg id

                        _ ->
                            Just createMsg

                else
                    Nothing
        , onTooLow = Nothing
        , onTooHigh = Nothing
        , onMouseEnter = \_ -> Nothing
        , onMouseLeave = \_ -> Just resetMsg
        , onMouseClick = selectMsg >> Just
        , separateSelections = False
        }


type alias DropdownMsgs msg =
    { inputMsg : String -> msg
    , mappingMsg : Menu.Msg -> msg
    , focusMsg : msg
    , blurMsg : msg
    , escapeMsg : msg
    , noOp : msg
    , removeMsg : String -> msg
    }


type alias DropdownConfig msg =
    { label : Maybe String
    , msgs : DropdownMsgs msg
    , displayFn : String -> Element Never
    , header : Maybe (Element msg)
    , placeholder : Maybe (Input.Placeholder msg)
    , inputAttrs : List (Attribute msg)
    }


viewDropdownInput : DropdownConfig msg -> Model -> List String -> Element msg
viewDropdownInput config dropdownModel itemsList =
    let
        { noOp, escapeMsg, inputMsg, focusMsg, blurMsg, removeMsg, mappingMsg } =
            config.msgs

        upDownEscDecoderHelper : Int -> D.Decoder msg
        upDownEscDecoderHelper code =
            if code == 38 || code == 40 then
                D.succeed noOp

            else if code == 27 then
                D.succeed escapeMsg

            else
                D.fail "not handling that key"

        upDownEscDecoder : D.Decoder ( msg, Bool )
        upDownEscDecoder =
            HE.keyCode
                |> D.andThen upDownEscDecoderHelper
                |> D.map (\msg -> ( msg, True ))

        removeAlreadySelected list =
            list
                |> List.filter
                    (\item -> not <| List.member item dropdownModel.selected)
    in
    column
        [ width fill ]
        [ column [ UI.smallSpacing, width fill ]
            [ config.label
                |> Maybe.map (\label -> el [ Font.bold, Font.color Color.darkerGrey, UI.mediumFont ] <| text label)
                |> Maybe.withDefault none
            , wrappedRow
                [ Border.width 1
                , Border.rounded 8
                , width fill
                , Border.color Color.lightGrey
                , Background.color Color.white
                , UI.smallSpacing
                , htmlAttribute <| HA.class "focus-within"
                , UI.mediumFont
                , paddingXY 5 0
                ]
                ((dropdownModel.selected
                    |> List.map
                        (\item ->
                            row UI.badgeAttrs
                                [ el [ UI.mediumFont, pointer, Events.onClick <| removeMsg item ] <| UI.viewIcon "close"
                                , Element.map (always noOp) <| el [ UI.smallFont ] <| text <| item
                                ]
                        )
                 )
                    ++ [ el [ htmlAttribute <| HA.class "no-focus", width fill ] <|
                            UI.textInput
                                [ Events.onFocus focusMsg
                                , htmlAttribute <| HE.preventDefaultOn "keydown" upDownEscDecoder
                                , htmlAttribute <| HE.on "blur" (blurDecoder noOp blurMsg)
                                , Border.width 0
                                , padding 0
                                ]
                                { onChange = inputMsg
                                , label = Nothing
                                , text = dropdownModel.query |> Maybe.withDefault ""
                                , placeholder = config.placeholder
                                }
                       ]
                )
            ]
        , Utils.viewIf dropdownModel.showMenu <|
            el
                [ inFront <|
                    column
                        [ UI.defaultSpacing
                        , Border.width 1
                        , Border.rounded 2
                        , Border.color Color.lightGrey
                        , Background.color Color.white
                        , htmlAttribute <| HA.style "z-index" "1"
                        , Font.color Color.grey
                        , moveDown 5
                        , padding 0
                        ]
                        [ config.header |> Maybe.withDefault none
                        , el [ width fill ] <|
                            html <|
                                Html.div [ HA.class "autocomplete-menu" ] <|
                                    if itemsList == [] then
                                        [ Html.div
                                            [ HA.style "padding" "10px"
                                            , HA.style "color" <|
                                                Color.colorToString Color.darkerGrey
                                            ]
                                            [ Html.text <|
                                                "Aucun résultat, appuyez sur Entrée pour ajouter \""
                                                    ++ (dropdownModel.query |> Maybe.withDefault "" |> Utils.capitalize)
                                                    ++ "\""
                                            ]
                                        ]

                                    else
                                        [ Html.map mappingMsg <|
                                            Menu.view (menuViewConfig config.displayFn) 10 dropdownModel.state (itemsList |> removeAlreadySelected)
                                        ]
                        ]
                , width <| minimum 300 <| fill
                ]
                none
        ]


blurDecoder : msg -> msg -> D.Decoder msg
blurDecoder noOp blurMsg =
    D.oneOf
        [ D.at [ "relatedTarget", "className" ] D.string
            |> D.andThen
                (\classes ->
                    if String.contains "list-item" classes then
                        -- clicked on a result in the list, should not send blur event
                        D.succeed noOp

                    else
                        -- clicked elsewhere, send blur event
                        D.succeed blurMsg
                )
        , D.succeed blurMsg
        ]


menuViewConfig : (String -> Element Never) -> Menu.ViewConfig String
menuViewConfig displayFn =
    let
        customizedLi keySelected mouseSelected selectedItem =
            { attributes =
                [ HA.classList
                    [ ( "autocomplete-item", True )
                    , ( "key-selected", keySelected || mouseSelected )
                    ]
                , HA.id <| selectedItem
                , HA.style "cursor" "pointer"
                , HA.style "list-style" "none"
                , HA.style "background-color" <|
                    if keySelected || mouseSelected then
                        Color.colorToString Color.lightestGrey

                    else
                        ""
                ]
            , children =
                [ displayFn selectedItem
                    |> layoutWith { options = [ noStaticStyleSheet, defaultFocusStyle ] } [ width fill ]
                    |> List.singleton
                    |> Html.div [ HA.class "list-item", HA.tabindex 0 ]
                ]
            }
    in
    Menu.viewConfig
        { toId = identity
        , ul =
            [ HA.class "autocomplete-list"
            , HA.style "padding" "0"
            , HA.style "margin-block-start" "0"
            , HA.style "margin-block-end" "0"
            ]
        , li = customizedLi
        }
