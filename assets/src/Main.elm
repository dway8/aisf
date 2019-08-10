module Main exposing (main)

import Aisf.Scalar exposing (Id(..))
import Api
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Http
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, top)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged newLocation ->
            handleUrlChange newLocation model

        UrlRequested urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                External _ ->
                    ( model, Cmd.none )

        GotChampions resp ->
            ( { model | champions = resp }, Cmd.none )

        GotChampion resp ->
            case ( model.currentPage, resp ) of
                ( ChampionPage id _, Success champion ) ->
                    if id == champion.id then
                        ( { model | currentPage = ChampionPage id resp }, Cmd.none )
                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleUrlChange : Url -> Model -> ( Model, Cmd Msg )
handleUrlChange newLocation model =
    let
        ( page, cmd ) =
            parseUrl newLocation
                |> getPageAndCmdFromRoute
    in
    ( { model | currentPage = page }, cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( page, cmd ) =
            parseUrl url
                |> getPageAndCmdFromRoute
    in
    ( { champions = NotAsked, currentPage = page, key = key }
    , cmd
    )


parseUrl : Url -> Route
parseUrl url =
    url
        |> parse
            (oneOf
                [ map ListRoute top
                , map ListRoute (s "champions")
                , map (\intId -> ChampionRoute <| Id (String.fromInt intId)) (s "champions" </> int)
                ]
            )
        |> Maybe.withDefault ListRoute


getPageAndCmdFromRoute : Route -> ( Page, Cmd Msg )
getPageAndCmdFromRoute route =
    case route of
        ListRoute ->
            ( ListPage, Api.getChampions )

        ChampionRoute id ->
            ( ChampionPage id Loading, Api.getChampion id )
