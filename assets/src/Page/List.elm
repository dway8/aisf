module Page.List exposing (view)

import Common
import Element exposing (..)
import Html.Attributes as HA
import Model exposing (Champion, ListPageModel, Msg(..), Sport)
import RemoteData exposing (RemoteData(..), WebData)


view : ListPageModel -> Element Msg
view model =
    column [ spacing 10 ]
        [ case model.champions of
            Success champions ->
                column [ spacing 20 ]
                    [ Common.sportSelector True model.sport
                    , row [ spacing 20 ]
                        [ column [ spacing 5 ]
                            (champions
                                |> filterBySport model.sport
                                |> List.map
                                    (\champ ->
                                        link [ htmlAttribute <| HA.class "champion-item" ]
                                            { url = "/champions/" ++ Model.getId champ
                                            , label = text <| champ.firstName ++ " " ++ champ.lastName
                                            }
                                    )
                            )
                        , link [] { url = "/champions/new", label = el [] <| text "Ajouter champion" }
                        ]
                    ]

            NotAsked ->
                none

            Loading ->
                text "..."

            _ ->
                text "Une erreur s'est produite."
        ]


filterBySport : Maybe Sport -> List Champion -> List Champion
filterBySport sport champions =
    case sport of
        Nothing ->
            champions

        Just s ->
            champions
                |> List.filter (.sport >> (==) s)
