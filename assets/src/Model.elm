module Model exposing (Champion, Champions, Flags, Model, Msg(..), Page(..), championsDecoder)

import Browser exposing (UrlRequest(..))
import Graphql.Http
import Json.Decode as D
import Json.Decode.Pipeline as P
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)


type alias Model =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , page : Page
    }


type Page
    = ListPage
    | ChampionPage


type alias Champions =
    List Champion


type alias Champion =
    { lastName : String
    , firstName : String
    }


type alias Flags =
    {}


type Msg
    = NoOp
    | ClickedLink UrlRequest
    | ChangedUrl Url
    | GotChampions (RemoteData (Graphql.Http.Error Champions) Champions)


championsDecoder : D.Decoder Champions
championsDecoder =
    D.list championDecoder


championDecoder : D.Decoder Champion
championDecoder =
    D.succeed Champion
        |> P.required "lastName" D.string
        |> P.required "firstName" D.string
