module Page.Records exposing (init, view)

import Api
import Common
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (Msg(..), Record, RecordType(..), RecordsPageModel, Specialty(..), Winner, Year)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : Year -> ( RecordsPageModel, Cmd Msg )
init currentYear =
    ( { records = Loading
      , newRecord = Nothing
      , currentYear = currentYear
      }
    , Api.getRecords
    )


view : Bool -> RecordsPageModel -> Element Msg
view isAdmin model =
    column [ UI.largeSpacing, width fill ]
        [ Utils.viewIf (isAdmin && model.newRecord == Nothing) <|
            (row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "plus", text "Ajouter un record" ]
                |> Button.makeButton (Just PressedAddRecordButton)
                |> Button.withBackgroundColor Color.green
                |> Button.viewButton
            )
        , Utils.viewIf isAdmin
            (model.newRecord
                |> Maybe.map (editNewRecord model.currentYear)
                |> Maybe.withDefault none
            )
        , case model.records of
            Success records ->
                column [ UI.largerSpacing ]
                    ([ ( "Triplés", Triple ), ( "Quatre premiers", FirstFour ), ( "Cinq premiers", FirstFive ), ( "Six premiers", FirstSix ) ]
                        |> List.map
                            (\( title, recordType ) ->
                                column [ UI.largeSpacing ]
                                    [ el [ Font.bold, UI.fontSize 6 ] <| text title
                                    , column [ UI.largeSpacing, paddingEach { top = 0, bottom = 0, left = 20, right = 0 } ]
                                        (records
                                            |> List.filter (.recordType >> (==) recordType)
                                            |> List.map viewRecord
                                        )
                                    ]
                            )
                    )

            NotAsked ->
                none

            Loading ->
                UI.spinner

            _ ->
                text "Une erreur s'est produite."
        ]


viewRecord : Record -> Element Msg
viewRecord record =
    column [ UI.defaultSpacing ]
        [ paragraph []
            [ el [ Font.bold ] <| text <| String.fromInt <| Model.getYear record.year
            , text " | "
            , text <| String.toUpper record.place
            , el [ Font.italic ] <| text " en "
            , el [ Font.italic ] <| text <| String.toLower <| Model.specialtyToDisplay record.specialty
            ]
        , wrappedRow [ UI.defaultSpacing ]
            (record.winners
                |> Dict.map
                    (\i w ->
                        row [ UI.smallSpacing ]
                            [ el
                                [ Background.color Color.blue
                                , Font.color Color.white
                                , Border.rounded 12
                                , width <| px 18
                                , height <| px 18
                                ]
                              <|
                                el [ centerX, centerY, UI.smallFont ] <|
                                    text <|
                                        String.fromInt i
                            , text <| w.firstName ++ " " ++ String.toUpper w.lastName
                            ]
                    )
                |> Dict.values
                |> List.intersperse (text "-")
            )
        ]


editNewRecord : Year -> Record -> Element Msg
editNewRecord currentYear newRecord =
    column [ UI.largeSpacing, width fill ]
        [ row [ UI.largeSpacing, width fill ]
            [ Common.yearSelector False currentYear SelectedAYear Nothing
            , specialtySelector
            , UI.textInput []
                { onChange = UpdatedNewRecordPlace
                , label = Nothing
                , text = newRecord.place
                , placeholder = Just <| Input.placeholder [ Font.italic ] <| text "Lieu"
                }
            , recordTypeSelector
            ]
        , editWinners newRecord.winners
        , row [ UI.defaultSpacing, alignRight ]
            [ text "Annuler"
                |> UI.smallButton (Just CancelledNewRecord)
                |> Button.withBackgroundColor Color.grey
                |> Button.viewButton
            , text "Valider"
                |> UI.smallButton (Just SaveNewRecord)
                |> Button.withBackgroundColor Color.green
                |> Button.viewButton
            ]
        ]


specialtySelector : Element Msg
specialtySelector =
    el [] <|
        html <|
            Html.select
                [ HE.on "change" <| D.map SelectedASpecialty <| HE.targetValue
                , HA.style "font-family" "Open Sans"
                , HA.style "font-size" "15px"
                ]
                ([ Geant, Combine, Slalom, SkiCross, Descente ]
                    |> List.map
                        (\specialty ->
                            Html.option
                                [ HA.value <| Model.specialtyToString specialty
                                ]
                                [ Html.text <| Model.specialtyToDisplay specialty ]
                        )
                )


recordTypeSelector : Element Msg
recordTypeSelector =
    el [] <|
        html <|
            Html.select
                [ HE.on "change" <| D.map SelectedARecordType <| HE.targetValue
                , HA.style "font-family" "Open Sans"
                , HA.style "font-size" "15px"
                ]
                ([ Triple, FirstFour, FirstFive, FirstSix ]
                    |> List.map
                        (\type_ ->
                            Html.option
                                [ HA.value <| String.fromInt <| Model.recordTypeToInt type_
                                ]
                                [ Html.text <| Model.recordTypeToDisplay type_ ]
                        )
                )


editWinners : Dict Int Winner -> Element Msg
editWinners winners =
    column [ UI.defaultSpacing, width fill ] (winners |> Dict.map editWinner |> Dict.values)


editWinner : Int -> Winner -> Element Msg
editWinner index winner =
    row [ width fill, UI.defaultSpacing, paddingEach { top = 0, bottom = 0, left = 50, right = 0 } ]
        [ el [ Font.bold ] <| text <| String.fromInt index ++ "."
        , UI.textInput []
            { onChange = UpdatedRecordWinnerLastName index
            , label = Nothing
            , text = winner.lastName
            , placeholder = Just <| Input.placeholder [ Font.italic ] <| text "NOM"
            }
        , UI.textInput []
            { onChange = UpdatedRecordWinnerFirstName index
            , label = Nothing
            , text = winner.firstName
            , placeholder = Just <| Input.placeholder [ Font.italic ] <| text "Prénom"
            }
        ]
