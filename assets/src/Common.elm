module Common exposing (..)

import Aisf.Scalar exposing (Id(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Route
import Table
import UI
import UI.Color as Color


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


specialtySelector : Bool -> Maybe Sport -> (String -> Msg) -> Maybe Specialty -> Element Msg
specialtySelector showOptionAll maybeSport msg currentSpecialty =
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
                                                , HA.selected (currentSpecialty == Just specialty)
                                                ]
                                                [ Html.text <| Model.specialtyToDisplay specialty ]
                                        )
                               )
                        )



-----------------------
------- TABLE ---------
-----------------------


tableCustomizations : Dict String (List (Html.Attribute msg)) -> Table.Customizations data msg
tableCustomizations attrsForHeaders =
    let
        default =
            Table.defaultCustomizations

        customThead headers =
            Table.HtmlDetails [] (List.map (simpleTheadHelp attrsForHeaders) headers)
    in
    { default
        | tableAttrs = [ HA.class "table table-hover table-striped table-middle" ]
        , thead =
            customThead
    }



-- thead code copied and customized from elm-sortable-table package


simpleTheadHelp : Dict String (List (Html.Attribute msg)) -> ( String, Table.Status, Html.Attribute msg ) -> Html.Html msg
simpleTheadHelp attrsForHeaders ( name, status, click ) =
    let
        content =
            case status of
                Table.Unsortable ->
                    [ Html.text name ]

                Table.Sortable selected ->
                    [ Html.text name
                    , if selected then
                        darkGrey "↓"

                      else
                        lightGrey "↓"
                    ]

                Table.Reversible Nothing ->
                    [ Html.text name
                    , lightGrey "↕"
                    ]

                Table.Reversible (Just isReversed) ->
                    [ Html.text name
                    , darkGrey
                        (if isReversed then
                            "↑"

                         else
                            "↓"
                        )
                    ]

        attrs =
            attrsForHeaders
                |> Dict.get name
                |> Maybe.withDefault []
    in
    Html.th (click :: (HA.style "border-bottom" <| "1px solid " ++ Color.colorToString Color.darkGrey) :: attrs) content


darkGrey : String -> Html.Html msg
darkGrey symbol =
    Html.span [ HA.style "color" <| Color.colorToString Color.darkGrey ] [ Html.text ("\u{00A0}" ++ symbol) ]


lightGrey : String -> Html.Html msg
lightGrey symbol =
    Html.span [ HA.style "color" <| Color.colorToString Color.lightGrey ] [ Html.text ("\u{00A0}" ++ symbol) ]


toRowAttrs : { a | id : Id } -> List (Html.Attribute Msg)
toRowAttrs champion =
    [ HA.class "champion-item", HE.onClick <| ChampionSelected champion.id, HA.style "cursor" "pointer" ]


defaultCell : List (Html.Attribute msg) -> Html.Html msg -> Table.HtmlDetails msg
defaultCell attrs htmlEl =
    Table.HtmlDetails (HA.style "vertical-align" "middle" :: [ HA.height 40 ] ++ attrs) [ htmlEl ]


centeredCell : List (Html.Attribute msg) -> Html.Html msg -> Table.HtmlDetails msg
centeredCell attrs htmlEl =
    Table.HtmlDetails ([ HA.style "vertical-align" "middle", HA.style "text-align" "center" ] ++ [ HA.height 40 ] ++ attrs) [ htmlEl ]


nameColumn : Table.Column Champion Msg
nameColumn =
    Table.veryCustomColumn
        { name = "NOM / PRÉNOM"
        , viewData = \champion -> defaultCell [] (Html.text <| Model.getName champion)
        , sorter = Table.decreasingOrIncreasingBy .lastName
        }


profilePictureColumn : Table.Column Champion Msg
profilePictureColumn =
    Table.veryCustomColumn
        { name = ""
        , viewData =
            \champion ->
                centeredCell [] <|
                    let
                        src =
                            case champion.profilePicture of
                                Just { filename } ->
                                    Route.baseEndpoint ++ "/uploads/" ++ filename

                                _ ->
                                    Model.resourcesEndpoint ++ "/images/no-profile-pic.jpg"
                    in
                    Html.img
                        [ HA.style "max-width" "35px"
                        , HA.style "max-height" "35px"
                        , HA.style "object-fit" "contain"
                        , HA.style "vertical-align" "middle"
                        , HA.src src
                        ]
                        []
        , sorter = Table.unsortable
        }


sportColumn : Table.Column { a | sport : Sport } Msg
sportColumn =
    Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData =
            \champion ->
                centeredCell [] (sportIconHtml champion.sport)
        , sorter = Table.decreasingOrIncreasingBy (.sport >> Model.sportToString)
        }


sportIconHtml : Sport -> Html Msg
sportIconHtml sport =
    Html.img
        [ HA.style "max-width" "35px"
        , HA.style "max-height" "35px"
        , HA.style "object-fit" "contain"
        , HA.style "vertical-align" "middle"
        , HA.src <| Model.resourcesEndpoint ++ "/images/" ++ Model.getSportIcon sport
        , HA.title <| Model.sportToString sport
        ]
        []


medalIconHtml : { a | competition : Competition, medalType : MedalType } -> Html Msg
medalIconHtml medal =
    Html.img
        [ HA.style "max-width" "25px"
        , HA.style "max-height" "25px"
        , HA.style "object-fit" "contain"
        , HA.style "vertical-align" "middle"
        , HA.src <| Model.resourcesEndpoint ++ "/images/" ++ Model.getMedalIcon medal.competition medal.medalType
        , HA.title <| Model.medalTypeToDisplay medal.medalType
        ]
        []


competitionColumn : Table.Column { a | competition : Competition } Msg
competitionColumn =
    Table.veryCustomColumn
        { name = "COMPÉTITION"
        , viewData = \a -> defaultCell [] (Html.text <| Model.competitionToDisplay a.competition)
        , sorter = Table.decreasingOrIncreasingBy (.competition >> Model.competitionToDisplay)
        }


yearColumn : Table.Column { a | year : Year } Msg
yearColumn =
    Table.veryCustomColumn
        { name = "ANNÉE"
        , viewData = \a -> centeredCell [] (Html.text <| String.fromInt <| Model.getYear a.year)
        , sorter = Table.decreasingOrIncreasingBy (.year >> Model.getYear)
        }


memberColumn : Table.Column { a | isMember : Bool } Msg
memberColumn =
    Table.veryCustomColumn
        { name = "MEMBRE"
        , viewData =
            \{ isMember } ->
                centeredCell []
                    (Html.img
                        [ HA.style "max-width" "25px"
                        , HA.style "max-height" "25px"
                        , HA.style "object-fit" "contain"
                        , HA.style "vertical-align" "middle"
                        , HA.src <| Model.resourcesEndpoint ++ "/images/" ++ Model.getIsMemberIcon isMember
                        ]
                        []
                    )
        , sorter =
            Table.decreasingOrIncreasingBy
                (\c ->
                    if c.isMember then
                        0

                    else
                        1
                )
        }



-----------------------
-----------------------
-----------------------


yearSelector : Bool -> Year -> (String -> Msg) -> Maybe Year -> Element Msg
yearSelector showOptionAll currentYear msg maybeSelectedYear =
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
                        [ Html.text "Toutes les années" ]
                    ]

                  else
                    []
                 )
                    ++ (List.range 1960 (Model.getYear currentYear)
                            |> List.reverse
                            |> List.map
                                (\year ->
                                    Html.option
                                        [ HA.value <| String.fromInt year
                                        , HA.selected (maybeSelectedYear == Just (Year year))
                                        ]
                                        [ Html.text <| String.fromInt year ]
                                )
                       )
                )


viewSearchQuery : Maybe String -> Element Msg
viewSearchQuery query =
    UI.textInput [ width fill ]
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


viewProfilePicture : Int -> Maybe Attachment -> Element Msg
viewProfilePicture widthPx profilePicture =
    el [ width <| px widthPx ] <|
        case profilePicture of
            Nothing ->
                el [ width fill ] none

            Just { filename } ->
                image [ width <| px widthPx ] { src = Route.baseEndpoint ++ "/uploads/" ++ filename, description = "Photo de profil" }


viewInfoRow : String -> Element Msg -> Element Msg
viewInfoRow title content =
    row [ UI.largeSpacing, width fill ]
        [ el
            [ Font.bold
            , Font.alignRight
            , alignTop
            , width <| fillPortion 2
            ]
          <|
            text title
        , paragraph [ Font.alignLeft, width <| fillPortion 5 ] [ content ]
        ]


viewBlock : String -> List (Element Msg) -> Element Msg
viewBlock title content =
    column [ UI.largeSpacing, width <| maximum 900 fill ]
        [ viewBlockTitle title
        , column [ UI.defaultSpacing, width fill ] content
        ]


viewBlockTitle : String -> Element Msg
viewBlockTitle title =
    el
        [ width fill
        , UI.largestFont
        , Font.color Color.blue
        , Font.bold
        , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
        , Border.color Color.blue
        , paddingEach { top = 0, bottom = 3, left = 0, right = 0 }
        ]
    <|
        text <|
            String.toUpper title


competitionSelector : Bool -> List Competition -> (String -> Msg) -> Maybe Competition -> Element Msg
competitionSelector showOptionAll competitionsList msg currentCompetition =
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
                        [ Html.text "Toutes les compétitions" ]
                    ]

                  else
                    []
                 )
                    ++ (competitionsList
                            |> List.map
                                (\competition ->
                                    Html.option
                                        [ HA.value <| Model.competitionToString competition
                                        , HA.selected (currentCompetition == Just competition)
                                        ]
                                        [ Html.text <| Model.competitionToDisplay competition ]
                                )
                       )
                )
