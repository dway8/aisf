-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Aisf.Query exposing (allChampions)

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


allChampions : SelectionSet decodesTo Aisf.Object.Champion -> SelectionSet (List decodesTo) RootQuery
allChampions object_ =
    Object.selectionForCompositeField "allChampions" [] object_ (identity >> Decode.list)
