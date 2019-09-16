-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Aisf.Object.ProExperience exposing (companyName, contact, description, id, occupationalCategory, title, website)

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


companyName : SelectionSet String Aisf.Object.ProExperience
companyName =
    Object.selectionForField "String" "companyName" [] Decode.string


contact : SelectionSet String Aisf.Object.ProExperience
contact =
    Object.selectionForField "String" "contact" [] Decode.string


description : SelectionSet String Aisf.Object.ProExperience
description =
    Object.selectionForField "String" "description" [] Decode.string


id : SelectionSet Aisf.ScalarCodecs.Id Aisf.Object.ProExperience
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Aisf.ScalarCodecs.codecs |> Aisf.Scalar.unwrapCodecs |> .codecId |> .decoder)


occupationalCategory : SelectionSet String Aisf.Object.ProExperience
occupationalCategory =
    Object.selectionForField "String" "occupationalCategory" [] Decode.string


title : SelectionSet String Aisf.Object.ProExperience
title =
    Object.selectionForField "String" "title" [] Decode.string


website : SelectionSet String Aisf.Object.ProExperience
website =
    Object.selectionForField "String" "website" [] Decode.string
