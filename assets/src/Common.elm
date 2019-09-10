module Common exposing (sportSelector, viewField, viewIf, viewMedal, viewProExperience)

import Browser.Navigation as Nav
import Dict
import Element exposing (..)
import Element.Font as Font
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)


sportSelector : Bool -> (String -> Msg) -> Maybe Sport -> Element Msg
sportSelector showOptionAll msg currentSport =
    let
        list =
            (if showOptionAll then
                [ "Tous les sports" ]

             else
                []
            )
                ++ List.map Model.sportToString Model.sportsList
    in
    el [] <|
        html <|
            Html.select
                [ HE.onInput msg
                , HA.style "font-family" "Roboto"
                , HA.style "font-size" "15px"
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


viewMedal : Medal -> Element Msg
viewMedal { competition, year, specialty, medalType } =
    column [ spacing 4 ]
        [ viewField "Compétition" (competition |> Model.competitionToDisplay)
        , viewField "Année" (year |> Model.getYear |> String.fromInt)
        , viewField "Spécialité" (specialty |> Model.specialtyToString)
        , viewField "Médaille" (medalType |> Model.medalTypeToDisplay)
        ]


viewIf : Bool -> Element Msg -> Element Msg
viewIf condition elem =
    if condition then
        elem

    else
        none
