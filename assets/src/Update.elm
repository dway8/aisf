module Update exposing (getPageAndCmdFromRoute, parseUrl, update)

import Aisf.Scalar exposing (Id(..))
import Api
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Graphql.Http
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, top)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlChanged newLocation ->
            handleUrlChange newLocation model

        UrlRequested urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                External _ ->
                    ( model, Cmd.none )

        GotChampions resp ->
            ( { model | currentPage = ListPage { champions = resp, sport = Nothing } }, Cmd.none )

        GotChampion resp ->
            case ( model.currentPage, resp ) of
                ( ChampionPage { id }, Success champion ) ->
                    if id == champion.id then
                        ( { model | currentPage = ChampionPage { id = id, champion = resp } }
                        , Cmd.none
                        )

                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UpdatedChampionField field val ->
            updateNewChampion field val model

        PressedSaveChampionButton ->
            case model.currentPage of
                NewChampionPage champion ->
                    ( model, Api.createChampion champion )

                _ ->
                    ( model, Cmd.none )

        GotCreateChampionResponse resp ->
            handleCreateChampionResponse resp model

        UpdatedChampionSport sportStr ->
            updateCurrentSport sportStr model

        FilteredBySport sportStr ->
            updateCurrentSport sportStr model

        PressedAddProExperienceButton ->
            addProExperience model


handleUrlChange : Url -> Model -> ( Model, Cmd Msg )
handleUrlChange newLocation model =
    let
        ( page, cmd ) =
            parseUrl newLocation
                |> getPageAndCmdFromRoute
    in
    ( { model | currentPage = page }, cmd )


parseUrl : Url -> Route
parseUrl url =
    url
        |> parse
            (oneOf
                [ map ListRoute top
                , map ListRoute (s "champions")
                , map NewChampionRoute (s "champions" </> s "new")
                , map (\intId -> ChampionRoute <| Id (String.fromInt intId)) (s "champions" </> int)
                ]
            )
        |> Maybe.withDefault ListRoute


getPageAndCmdFromRoute : Route -> ( Page, Cmd Msg )
getPageAndCmdFromRoute route =
    case route of
        ListRoute ->
            ( ListPage (ListPageModel Loading Nothing), Api.getChampions )

        ChampionRoute id ->
            ( ChampionPage (ChampionPageModel id Loading), Api.getChampion id )

        NewChampionRoute ->
            ( NewChampionPage Model.initChampion, Cmd.none )


updateNewChampion : FormField -> String -> Model -> ( Model, Cmd Msg )
updateNewChampion field val model =
    case model.currentPage of
        NewChampionPage champion ->
            let
                newChamp =
                    case field of
                        FirstName ->
                            { champion | firstName = val }

                        LastName ->
                            { champion | lastName = val }

                        Email ->
                            { champion | email = val }
            in
            ( { model | currentPage = NewChampionPage newChamp }, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleCreateChampionResponse : RemoteData (Graphql.Http.Error (Maybe Champion)) (Maybe Champion) -> Model -> ( Model, Cmd Msg )
handleCreateChampionResponse response model =
    case response of
        Success _ ->
            ( model, Nav.pushUrl model.key "/" )

        _ ->
            ( model, Cmd.none )


updateCurrentSport : String -> Model -> ( Model, Cmd Msg )
updateCurrentSport sportStr model =
    case model.currentPage of
        NewChampionPage champion ->
            let
                newChamp =
                    { champion | sport = Model.sportFromString sportStr |> Maybe.withDefault champion.sport }
            in
            ( { model | currentPage = NewChampionPage newChamp }, Cmd.none )

        ListPage lModel ->
            ( { model
                | currentPage =
                    ListPage
                        { lModel | sport = Model.sportFromString sportStr }
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


addProExperience : Model -> ( Model, Cmd Msg )
addProExperience model =
    ( model, Cmd.none )
