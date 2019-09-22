module Common exposing (..)

import Aisf.Scalar exposing (Id(..))
import Browser.Navigation as Nav
import Dict
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Table


sportSelector : Bool -> Maybe Sport -> Element Msg
sportSelector showOptionAll currentSport =
    let
        list =
            (if showOptionAll then
                [ "Toutes les disciplines" ]

             else
                []
            )
                ++ List.map Model.sportToString Model.sportsList
    in
    el [] <|
        html <|
            Html.select
                [ HE.on "change" <| D.map SelectedASport <| HE.targetValue
                , HA.style "font-family" "Open Sans"
                , HA.style "font-size" "15px"
                , HA.id "sport-selector"
                ]
                (List.map (viewSportOption currentSport) list)


viewSportOption : Maybe Sport -> String -> Html.Html msg
viewSportOption currentSport sport =
    Html.option
        [ HA.value sport
        , HA.selected <| currentSport == Model.sportFromString sport
        ]
        [ Html.text sport ]


viewProExperience : ProExperience -> Element Msg
viewProExperience exp =
    column [ spacing 4 ]
        [ viewField "Catégorie professionnelle" exp.occupationalCategory
        , viewField "Titre" exp.title
        , viewField "Nom de l'entreprise" exp.companyName
        , viewField "Description" exp.description
        , viewField "Site internet" exp.website
        , viewField "Contact" exp.contact
        ]


viewField : String -> String -> Element Msg
viewField label value =
    row [ spacing 10 ] [ text label, el [ Font.bold ] <| text value ]


viewTextArea : String -> String -> Element Msg
viewTextArea label value =
    column [ spacing 5 ] [ text label, el [ Font.bold ] <| text value ]


viewMedal : Medal -> Element Msg
viewMedal { competition, year, specialty, medalType } =
    column [ spacing 4 ]
        [ viewField "Compétition" (competition |> Model.competitionToDisplay)
        , viewField "Année" (year |> Model.getYear |> String.fromInt)
        , viewField "Spécialité" (specialty |> Model.specialtyToDisplay)
        , viewField "Médaille" (medalType |> Model.medalTypeToDisplay)
        ]


specialtySelector : Bool -> Maybe Sport -> (String -> Msg) -> Element Msg
specialtySelector showOptionAll maybeSport msg =
    case maybeSport of
        Nothing ->
            text "Veuillez choisir d'abord une discipline"

        Just sport ->
            el [] <|
                html <|
                    Html.select
                        [ HE.on "change" <| D.map msg <| HE.targetValue
                        , HA.style "font-family" "Open Sans"
                        , HA.style "font-size" "15px"
                        ]
                        ((if showOptionAll then
                            [ Html.option
                                []
                                [ Html.text "Toutes les spécialités" ]
                            ]

                          else
                            []
                         )
                            ++ (Model.getSpecialtiesForSport sport
                                    |> List.map
                                        (\specialty ->
                                            Html.option
                                                [ HA.value <| Model.specialtyToString specialty
                                                ]
                                                [ Html.text <| Model.specialtyToDisplay specialty ]
                                        )
                               )
                        )



-----------------------
------- TABLE ---------
-----------------------


tableCustomizations : Table.Customizations data msg
tableCustomizations =
    let
        default =
            Table.defaultCustomizations
    in
    { default | tableAttrs = [ HA.class "table table-hover table-striped table-middle" ] }


toRowAttrs : { a | id : Id } -> List (Html.Attribute Msg)
toRowAttrs champion =
    [ HA.class "champion-item", HE.onClick <| ChampionSelected champion.id, HA.style "cursor" "pointer" ]


defaultCell : List (Html.Attribute msg) -> Html.Html msg -> Table.HtmlDetails msg
defaultCell attrs htmlEl =
    Table.HtmlDetails (HA.style "vertical-align" "middle" :: attrs) [ htmlEl ]



-----------------------
-----------------------
-----------------------


yearSelector : Bool -> Year -> (String -> Msg) -> Element Msg
yearSelector showOptionAll currentYear msg =
    let
        list : List String
        list =
            (if showOptionAll then
                [ "Toutes les années" ]

             else
                []
            )
                ++ (List.range 1960 (Model.getYear currentYear)
                        |> List.map String.fromInt
                   )
    in
    el [] <|
        html <|
            Html.select
                [ HE.on "change" <| D.map msg <| HE.targetValue
                , HA.style "font-family" "Open Sans"
                , HA.style "font-size" "15px"
                ]
                (list
                    |> List.map
                        (\year ->
                            Html.option
                                [ HA.value year
                                ]
                                [ Html.text year ]
                        )
                )


viewTextInput : Maybe String -> Maybe String -> String -> (String -> Msg) -> Element Msg
viewTextInput label placeholder value msg =
    Input.text
        [ Border.solid
        , Border.rounded 8
        , paddingXY 13 7
        , width shrink
        ]
        { onChange = msg
        , text = value
        , placeholder =
            placeholder
                |> Maybe.map (\p -> Input.placeholder [ Font.size 14, Font.italic ] <| el [ centerY ] <| text p)
        , label =
            label
                |> Maybe.map
                    (\l ->
                        Input.labelAbove [ paddingEach { bottom = 4, right = 0, left = 0, top = 0 }, Font.bold ] <|
                            paragraph [] [ text l ]
                    )
                |> Maybe.withDefault (Input.labelHidden "")
        }
