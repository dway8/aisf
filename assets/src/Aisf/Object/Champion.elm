-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Aisf.Object.Champion exposing (address, background, bestMemory, birthDate, decoration, email, firstName, frenchTeamParticipation, highlights, id, intro, isMember, lastName, login, medals, olympicGamesParticipation, phoneNumber, pictures, proExperiences, profilePictureFilename, sport, trackRecord, volunteering, website, worldCupParticipation, yearsInFrenchTeam)

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


address : SelectionSet (Maybe String) Aisf.Object.Champion
address =
    Object.selectionForField "(Maybe String)" "address" [] (Decode.string |> Decode.nullable)


background : SelectionSet (Maybe String) Aisf.Object.Champion
background =
    Object.selectionForField "(Maybe String)" "background" [] (Decode.string |> Decode.nullable)


bestMemory : SelectionSet (Maybe String) Aisf.Object.Champion
bestMemory =
    Object.selectionForField "(Maybe String)" "bestMemory" [] (Decode.string |> Decode.nullable)


birthDate : SelectionSet (Maybe String) Aisf.Object.Champion
birthDate =
    Object.selectionForField "(Maybe String)" "birthDate" [] (Decode.string |> Decode.nullable)


decoration : SelectionSet (Maybe String) Aisf.Object.Champion
decoration =
    Object.selectionForField "(Maybe String)" "decoration" [] (Decode.string |> Decode.nullable)


email : SelectionSet (Maybe String) Aisf.Object.Champion
email =
    Object.selectionForField "(Maybe String)" "email" [] (Decode.string |> Decode.nullable)


firstName : SelectionSet String Aisf.Object.Champion
firstName =
    Object.selectionForField "String" "firstName" [] Decode.string


frenchTeamParticipation : SelectionSet (Maybe String) Aisf.Object.Champion
frenchTeamParticipation =
    Object.selectionForField "(Maybe String)" "frenchTeamParticipation" [] (Decode.string |> Decode.nullable)


highlights : SelectionSet (Maybe (List String)) Aisf.Object.Champion
highlights =
    Object.selectionForField "(Maybe (List String))" "highlights" [] (Decode.string |> Decode.list |> Decode.nullable)


id : SelectionSet Aisf.ScalarCodecs.Id Aisf.Object.Champion
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Aisf.ScalarCodecs.codecs |> Aisf.Scalar.unwrapCodecs |> .codecId |> .decoder)


intro : SelectionSet (Maybe String) Aisf.Object.Champion
intro =
    Object.selectionForField "(Maybe String)" "intro" [] (Decode.string |> Decode.nullable)


isMember : SelectionSet Bool Aisf.Object.Champion
isMember =
    Object.selectionForField "Bool" "isMember" [] Decode.bool


lastName : SelectionSet String Aisf.Object.Champion
lastName =
    Object.selectionForField "String" "lastName" [] Decode.string


login : SelectionSet (Maybe Int) Aisf.Object.Champion
login =
    Object.selectionForField "(Maybe Int)" "login" [] (Decode.int |> Decode.nullable)


medals : SelectionSet decodesTo Aisf.Object.Medal -> SelectionSet (List decodesTo) Aisf.Object.Champion
medals object_ =
    Object.selectionForCompositeField "medals" [] object_ (identity >> Decode.list)


olympicGamesParticipation : SelectionSet (Maybe String) Aisf.Object.Champion
olympicGamesParticipation =
    Object.selectionForField "(Maybe String)" "olympicGamesParticipation" [] (Decode.string |> Decode.nullable)


phoneNumber : SelectionSet (Maybe String) Aisf.Object.Champion
phoneNumber =
    Object.selectionForField "(Maybe String)" "phoneNumber" [] (Decode.string |> Decode.nullable)


pictures : SelectionSet decodesTo Aisf.Object.Picture -> SelectionSet (List decodesTo) Aisf.Object.Champion
pictures object_ =
    Object.selectionForCompositeField "pictures" [] object_ (identity >> Decode.list)


proExperiences : SelectionSet decodesTo Aisf.Object.ProExperience -> SelectionSet (List decodesTo) Aisf.Object.Champion
proExperiences object_ =
    Object.selectionForCompositeField "proExperiences" [] object_ (identity >> Decode.list)


profilePictureFilename : SelectionSet (Maybe String) Aisf.Object.Champion
profilePictureFilename =
    Object.selectionForField "(Maybe String)" "profilePictureFilename" [] (Decode.string |> Decode.nullable)


sport : SelectionSet String Aisf.Object.Champion
sport =
    Object.selectionForField "String" "sport" [] Decode.string


trackRecord : SelectionSet (Maybe String) Aisf.Object.Champion
trackRecord =
    Object.selectionForField "(Maybe String)" "trackRecord" [] (Decode.string |> Decode.nullable)


volunteering : SelectionSet (Maybe String) Aisf.Object.Champion
volunteering =
    Object.selectionForField "(Maybe String)" "volunteering" [] (Decode.string |> Decode.nullable)


website : SelectionSet (Maybe String) Aisf.Object.Champion
website =
    Object.selectionForField "(Maybe String)" "website" [] (Decode.string |> Decode.nullable)


worldCupParticipation : SelectionSet (Maybe String) Aisf.Object.Champion
worldCupParticipation =
    Object.selectionForField "(Maybe String)" "worldCupParticipation" [] (Decode.string |> Decode.nullable)


yearsInFrenchTeam : SelectionSet (Maybe (List Int)) Aisf.Object.Champion
yearsInFrenchTeam =
    Object.selectionForField "(Maybe (List Int))" "yearsInFrenchTeam" [] (Decode.int |> Decode.list |> Decode.nullable)
