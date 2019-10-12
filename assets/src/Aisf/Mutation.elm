-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Aisf.Mutation exposing (CreateChampionOptionalArguments, CreateChampionRequiredArguments, UpdateChampionOptionalArguments, UpdateChampionRequiredArguments, createChampion, updateChampion)

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


type alias CreateChampionOptionalArguments =
    { background : OptionalArgument String
    , bestMemory : OptionalArgument String
    , decoration : OptionalArgument String
    , email : OptionalArgument String
    , frenchTeamParticipation : OptionalArgument String
    , intro : OptionalArgument String
    , olympicGamesParticipation : OptionalArgument String
    , trackRecord : OptionalArgument String
    , volunteering : OptionalArgument String
    , worldCupParticipation : OptionalArgument String
    }


type alias CreateChampionRequiredArguments =
    { firstName : String
    , highlights : List String
    , isMember : Bool
    , lastName : String
    , medals : List Aisf.InputObject.MedalParams
    , pictures : List Aisf.InputObject.PictureParams
    , proExperiences : List Aisf.InputObject.ProExperienceParams
    , sport : String
    , yearsInFrenchTeam : List Int
    }


createChampion : (CreateChampionOptionalArguments -> CreateChampionOptionalArguments) -> CreateChampionRequiredArguments -> SelectionSet decodesTo Aisf.Object.Champion -> SelectionSet (Maybe decodesTo) RootMutation
createChampion fillInOptionals requiredArgs object_ =
    let
        filledInOptionals =
            fillInOptionals { background = Absent, bestMemory = Absent, decoration = Absent, email = Absent, frenchTeamParticipation = Absent, intro = Absent, olympicGamesParticipation = Absent, trackRecord = Absent, volunteering = Absent, worldCupParticipation = Absent }

        optionalArgs =
            [ Argument.optional "background" filledInOptionals.background Encode.string, Argument.optional "bestMemory" filledInOptionals.bestMemory Encode.string, Argument.optional "decoration" filledInOptionals.decoration Encode.string, Argument.optional "email" filledInOptionals.email Encode.string, Argument.optional "frenchTeamParticipation" filledInOptionals.frenchTeamParticipation Encode.string, Argument.optional "intro" filledInOptionals.intro Encode.string, Argument.optional "olympicGamesParticipation" filledInOptionals.olympicGamesParticipation Encode.string, Argument.optional "trackRecord" filledInOptionals.trackRecord Encode.string, Argument.optional "volunteering" filledInOptionals.volunteering Encode.string, Argument.optional "worldCupParticipation" filledInOptionals.worldCupParticipation Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "createChampion" (optionalArgs ++ [ Argument.required "firstName" requiredArgs.firstName Encode.string, Argument.required "highlights" requiredArgs.highlights (Encode.string |> Encode.list), Argument.required "isMember" requiredArgs.isMember Encode.bool, Argument.required "lastName" requiredArgs.lastName Encode.string, Argument.required "medals" requiredArgs.medals (Aisf.InputObject.encodeMedalParams |> Encode.list), Argument.required "pictures" requiredArgs.pictures (Aisf.InputObject.encodePictureParams |> Encode.list), Argument.required "proExperiences" requiredArgs.proExperiences (Aisf.InputObject.encodeProExperienceParams |> Encode.list), Argument.required "sport" requiredArgs.sport Encode.string, Argument.required "yearsInFrenchTeam" requiredArgs.yearsInFrenchTeam (Encode.int |> Encode.list) ]) object_ (identity >> Decode.nullable)


type alias UpdateChampionOptionalArguments =
    { background : OptionalArgument String
    , bestMemory : OptionalArgument String
    , decoration : OptionalArgument String
    , email : OptionalArgument String
    , frenchTeamParticipation : OptionalArgument String
    , intro : OptionalArgument String
    , olympicGamesParticipation : OptionalArgument String
    , profilePicture : OptionalArgument Aisf.InputObject.FileParams
    , trackRecord : OptionalArgument String
    , volunteering : OptionalArgument String
    , worldCupParticipation : OptionalArgument String
    }


type alias UpdateChampionRequiredArguments =
    { firstName : String
    , highlights : List String
    , id : String
    , isMember : Bool
    , lastName : String
    , medals : List Aisf.InputObject.MedalParams
    , pictures : List Aisf.InputObject.PictureParams
    , proExperiences : List Aisf.InputObject.ProExperienceParams
    , sport : String
    , yearsInFrenchTeam : List Int
    }


updateChampion : (UpdateChampionOptionalArguments -> UpdateChampionOptionalArguments) -> UpdateChampionRequiredArguments -> SelectionSet decodesTo Aisf.Object.Champion -> SelectionSet (Maybe decodesTo) RootMutation
updateChampion fillInOptionals requiredArgs object_ =
    let
        filledInOptionals =
            fillInOptionals { background = Absent, bestMemory = Absent, decoration = Absent, email = Absent, frenchTeamParticipation = Absent, intro = Absent, olympicGamesParticipation = Absent, profilePicture = Absent, trackRecord = Absent, volunteering = Absent, worldCupParticipation = Absent }

        optionalArgs =
            [ Argument.optional "background" filledInOptionals.background Encode.string, Argument.optional "bestMemory" filledInOptionals.bestMemory Encode.string, Argument.optional "decoration" filledInOptionals.decoration Encode.string, Argument.optional "email" filledInOptionals.email Encode.string, Argument.optional "frenchTeamParticipation" filledInOptionals.frenchTeamParticipation Encode.string, Argument.optional "intro" filledInOptionals.intro Encode.string, Argument.optional "olympicGamesParticipation" filledInOptionals.olympicGamesParticipation Encode.string, Argument.optional "profilePicture" filledInOptionals.profilePicture Aisf.InputObject.encodeFileParams, Argument.optional "trackRecord" filledInOptionals.trackRecord Encode.string, Argument.optional "volunteering" filledInOptionals.volunteering Encode.string, Argument.optional "worldCupParticipation" filledInOptionals.worldCupParticipation Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "updateChampion" (optionalArgs ++ [ Argument.required "firstName" requiredArgs.firstName Encode.string, Argument.required "highlights" requiredArgs.highlights (Encode.string |> Encode.list), Argument.required "id" requiredArgs.id Encode.string, Argument.required "isMember" requiredArgs.isMember Encode.bool, Argument.required "lastName" requiredArgs.lastName Encode.string, Argument.required "medals" requiredArgs.medals (Aisf.InputObject.encodeMedalParams |> Encode.list), Argument.required "pictures" requiredArgs.pictures (Aisf.InputObject.encodePictureParams |> Encode.list), Argument.required "proExperiences" requiredArgs.proExperiences (Aisf.InputObject.encodeProExperienceParams |> Encode.list), Argument.required "sport" requiredArgs.sport Encode.string, Argument.required "yearsInFrenchTeam" requiredArgs.yearsInFrenchTeam (Encode.int |> Encode.list) ]) object_ (identity >> Decode.nullable)
