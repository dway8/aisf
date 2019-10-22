module Page.Login exposing (init, view)

import Api
import Common
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (LoginPageModel, LoginResponse(..), Msg(..), Winner, Year)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : ( LoginPageModel, Cmd Msg )
init =
    ( { loginId = ""
      , lastName = ""
      , loginRequest = NotAsked
      }
    , Cmd.none
    )


view : LoginPageModel -> Element Msg
view model =
    el [ centerX, centerY, Background.color Color.lightestGrey, paddingXY 60 40, width <| px 400 ] <|
        column [ width fill, spacing 40 ]
            [ el [ UI.largestFont, Font.color Color.blue, Font.bold, centerX ] <| text "ESPACE CHAMPION"
            , column [ width fill, UI.largeSpacing ]
                [ UI.textInput []
                    { onChange = UpdatedLoginNameField
                    , label = Just "Nom"
                    , text = model.lastName
                    , placeholder = Nothing
                    }
                , UI.textInput []
                    { onChange = UpdatedLoginIdField
                    , label = Just "Mot de passe"
                    , text = model.loginId
                    , placeholder = Nothing
                    }
                ]
            , text "Connexion"
                |> Button.makeButton (Just PressedLoginButton)
                |> Button.withBackgroundColor Color.green
                |> Button.withAttrs [ centerX ]
                |> Button.viewButton
            , case model.loginRequest of
                Success Denied ->
                    paragraph [ Font.center, Font.color Color.red, width fill ] [ text "Aucun compte champion n'a été trouvé avec ces identifiants." ]

                Failure _ ->
                    paragraph [ Font.center, Font.color Color.red, width fill ] [ text "Une erreur s'est produite. Veuillez réessayer." ]

                _ ->
                    none
            ]
