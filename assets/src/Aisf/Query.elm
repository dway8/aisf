-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Aisf.Query exposing (ChampionRequiredArguments, LoginRequiredArguments, champion, champions, events, login, records, sectors)

import Aisf.InputObject
import Aisf.Interface
import Aisf.Object
import Aisf.Scalar
import Aisf.ScalarCodecs
import Aisf.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)


type alias ChampionRequiredArguments =
    { id : Aisf.ScalarCodecs.Id }


champion : ChampionRequiredArguments -> SelectionSet decodesTo Aisf.Object.Champion -> SelectionSet decodesTo RootQuery
champion requiredArgs object_ =
    Object.selectionForCompositeField "champion" [ Argument.required "id" requiredArgs.id (Aisf.ScalarCodecs.codecs |> Aisf.Scalar.unwrapEncoder .codecId) ] object_ identity


champions : SelectionSet decodesTo Aisf.Object.ChampionLite -> SelectionSet (List decodesTo) RootQuery
champions object_ =
    Object.selectionForCompositeField "champions" [] object_ (identity >> Decode.list)


events : SelectionSet decodesTo Aisf.Object.Event -> SelectionSet (List decodesTo) RootQuery
events object_ =
    Object.selectionForCompositeField "events" [] object_ (identity >> Decode.list)


type alias LoginRequiredArguments =
    { lastName : String
    , loginId : String
    }


login : LoginRequiredArguments -> SelectionSet decodesTo Aisf.Object.LoginResponse -> SelectionSet decodesTo RootQuery
login requiredArgs object_ =
    Object.selectionForCompositeField "login" [ Argument.required "lastName" requiredArgs.lastName Encode.string, Argument.required "loginId" requiredArgs.loginId Encode.string ] object_ identity


records : SelectionSet decodesTo Aisf.Object.Record -> SelectionSet (List decodesTo) RootQuery
records object_ =
    Object.selectionForCompositeField "records" [] object_ (identity >> Decode.list)


sectors : SelectionSet decodesTo Aisf.Object.Sector -> SelectionSet (List decodesTo) RootQuery
sectors object_ =
    Object.selectionForCompositeField "sectors" [] object_ (identity >> Decode.list)
