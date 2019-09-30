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
import UI


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
        [ UI.viewField "Secteur d'activité" exp.sector.name
        , UI.viewField "Titre" exp.title
        , UI.viewField "Nom de l'entreprise" exp.companyName
        , UI.viewField "Description" exp.description
        , UI.viewField "Site internet" exp.website
        , UI.viewField "Contact" exp.contact
        ]


viewTextArea : String -> String -> Element Msg
viewTextArea label value =
    column [ spacing 5 ] [ text label, el [ Font.bold ] <| text value ]


viewMedal : Medal -> Element Msg
viewMedal { competition, year, specialty, medalType } =
    column [ spacing 4 ]
        [ UI.viewField "Compétition" (competition |> Model.competitionToDisplay)
        , UI.viewField "Année" (year |> Model.getYear |> String.fromInt)
        , UI.viewField "Spécialité" (specialty |> Model.specialtyToDisplay)
        , UI.viewField "Médaille" (medalType |> Model.medalTypeToDisplay)
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


viewSearchQuery : Maybe String -> Element Msg
viewSearchQuery query =
    UI.textInput []
        { onChange = UpdatedSearchQuery
        , label = Nothing
        , text = query |> Maybe.withDefault ""
        , placeholder = Just <| Input.placeholder [ Font.size 14, Font.italic ] <| el [ centerY ] <| text "Rechercher un champion..."
        }


filterBySearchQuery : Maybe String -> List Champion -> List Champion
filterBySearchQuery query champions =
    case query of
        Nothing ->
            champions

        Just str ->
            let
                lowerStr =
                    String.toLower str
            in
            champions
                |> List.filter
                    (\champ ->
                        String.contains lowerStr (String.toLower champ.lastName)
                            || String.contains lowerStr (String.toLower champ.firstName)
                    )
