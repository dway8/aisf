-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Aisf.Object.Sector exposing (id, name)

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
import Json.Decode as Decode


id : SelectionSet Aisf.ScalarCodecs.Id Aisf.Object.Sector
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Aisf.ScalarCodecs.codecs |> Aisf.Scalar.unwrapCodecs |> .codecId |> .decoder)


name : SelectionSet String Aisf.Object.Sector
name =
    Object.selectionForField "String" "name" [] Decode.string
