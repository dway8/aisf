module Page.Records exposing (init, view)

import Api
import Common
import Dict exposing (Dict)
import Element exposing (..)
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
        [ Utils.viewIf isAdmin <|
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
                                    , column [ UI.largeSpacing ]
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
        [ paragraph [ Font.italic, Font.bold ]
            [ el [] <| text <| String.fromInt <| Model.getYear record.year
            , text "\u{00A0}: "
            , text <| String.toUpper record.place
            , text " en "
            , text <| String.toLower <| Model.specialtyToDisplay record.specialty
            ]
        , row [ UI.defaultSpacing ]
            (record.winners
                |> Dict.map (\i w -> text <| String.fromInt i ++ ". " ++ w.firstName ++ " " ++ String.toUpper w.lastName)
                |> Dict.values
                |> List.intersperse (text "-")
            )
        ]


editNewRecord : Year -> Record -> Element Msg
editNewRecord currentYear newRecord =
    column [ UI.largeSpacing ]
        [ row [ UI.largeSpacing ]
            [ Common.yearSelector False currentYear SelectedAYear
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
        , row [ UI.largeSpacing ]
            [ text "Valider"
                |> Button.makeButton (Just SaveNewRecord)
                |> Button.withFontColor Color.green
                |> Button.viewButton
            , text "Annuler"
                |> Button.makeButton (Just CancelledNewRecord)
                |> Button.withFontColor Color.red
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
    column [ UI.defaultSpacing ] (winners |> Dict.map editWinner |> Dict.values)


editWinner : Int -> Winner -> Element Msg
editWinner index winner =
    row [ UI.defaultSpacing ]
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
