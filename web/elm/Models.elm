module Models exposing (..)

import Dict as D
import List.Extra exposing (dropWhile)
import Maybe exposing (withDefault)
import Types exposing (..)


blankStory : Story
blankStory =
    { title = "A story", author = "Me", summary = "this is a summary", content = "this is some story content", url = "#", id = -1, feedId = -1, updated = "", read = False, score = 0 }


errStory : a -> Story
errStory e =
    { title = "Something went wrong", summary = (toString e), author = "Me", content = (toString e), url = "", id = -2, feedId = -2, updated = "", read = False, score = 0 }


storyForId : Int -> List Story -> Maybe Story
storyForId targetId storyList =
    List.head <| List.filter (\s -> s.id == targetId) storyList


nextOrHead : Maybe Story -> List Story -> Maybe Story
nextOrHead story storyList =
    case story of
        Just s ->
            findNext story storyList

        Nothing ->
            List.head storyList


findNext : Maybe Story -> List Story -> Maybe Story
findNext target currList =
    case target of
        Nothing ->
            Nothing

        Just targetStory ->
            case currList of
                [] ->
                    Nothing

                hd :: [] ->
                    Nothing

                hd :: next :: tl ->
                    if hd.id == targetStory.id then
                        Just next
                    else
                        findNext target <| next :: tl


findRest : Maybe Story -> List Story -> List Story
findRest target currList =
    case target of
        Just targetStory ->
            currList
                |> dropWhile (\s -> not <| s.id == targetStory.id)
                |> List.tail
                |> withDefault []

        Nothing ->
            currList


storySort : Story -> Story -> Order
storySort a b =
    case compare a.score b.score of
        GT ->
            GT

        LT ->
            LT

        EQ ->
            compare a.id b.id


storyDictToList : StoryDict -> List Story
storyDictToList stories =
    List.reverse <| List.sortWith storySort <| List.map Tuple.second <| D.toList stories


storyListToDict : List Story -> StoryDict
storyListToDict stories =
    D.fromList <| List.map (\s -> ( s.id, s )) stories


feedListToDict : List Feed -> FeedDict
feedListToDict stories =
    D.fromList <| List.map (\s -> ( s.id, s )) stories


storyInFeed : Feed -> Int -> Story -> Bool
storyInFeed feed storyId story =
    feed.id == story.feedId


currentStories : Model -> StoryDict
currentStories model =
    case model.currentFeed of
        Nothing ->
            model.stories

        Just feed ->
            D.filter (storyInFeed feed) model.stories


initialModel : Model
initialModel =
    { stories = D.fromList []
    , feeds = D.fromList []
    , requestStatus = { status = "init" }
    , feedToAdd = ""
    , currentStory = Nothing
    , currentFeed = Nothing
    , currentView = StoryView
    , controlPanelVisible = False
    , showDebug = False
    , storyDisplayType = Full
    }


feedForStory : Model -> Story -> Maybe Feed
feedForStory model story =
    D.get story.feedId model.feeds


feedTitleForStory : Model -> Story -> String
feedTitleForStory model story =
    case feedForStory model story of
        Just feed ->
            feed.title

        Nothing ->
            "Unknown Feed"
