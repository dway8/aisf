module Model exposing (Champion, Champions, Flags, Model, Msg(..), Page(..), Route(..), getId)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Graphql.Http
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)


type alias Model =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , currentPage : Page
    , key : Nav.Key
    }


type Page
    = ListPage
    | ChampionPage Id (RemoteData (Graphql.Http.Error Champion) Champion)


type Route
    = ListRoute
    | ChampionRoute Id


type alias Champions =
    List Champion


type alias Champion =
    { id : Id
    , lastName : String
    , firstName : String
    }


getId : Champion -> String
getId { id } =
    case id of
        Id str ->
            str


type alias Flags =
    {}


type Msg
    = NoOp
    | UrlRequested UrlRequest
    | UrlChanged Url
    | GotChampions (RemoteData (Graphql.Http.Error Champions) Champions)
    | GotChampion (RemoteData (Graphql.Http.Error Champion) Champion)
