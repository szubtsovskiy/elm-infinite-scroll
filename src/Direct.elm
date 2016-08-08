module Direct exposing (main)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick, on)
import Html.Attributes exposing (..)
import Http
import Task
import Json.Decode as Json
import String exposing (split)
import List exposing (map)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model =
  { items : List String
  }

type alias Pos =
  { scrollTop : Int
  , contentHeight : Int
  , containerHeight : Int
  }

type Action
  = FetchItems Int Bool
    | FetchSucceed String
    | FetchFail Http.Error
    | Scroll Pos

-- UPDATE

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    FetchItems amount startWithLoremIpsum ->
      (model, fetchLoremIpsum amount startWithLoremIpsum)

    FetchSucceed lipsum ->
      ({model | items = model.items ++ (split "\n" lipsum)}, Cmd.none)


    FetchFail err ->
      let
        _ =
          Debug.log "Error: " (toString err)
      in
        (model, Cmd.none)

    Scroll {scrollTop, contentHeight, containerHeight} ->
      let
        _ =
          Debug.log "Scroll: " (toString (scrollTop, contentHeight, containerHeight))
      in
        (model, Cmd.none)

fetchLoremIpsum : Int -> Bool -> Cmd Action
fetchLoremIpsum amount startWithLoremIpsum =
  let
    url = "http://lipsum.com/feed/json?what=paras"
          ++ "&amount=" ++ (toString amount)
          ++ "&start=" ++ (if startWithLoremIpsum then "yes" else "no")
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeLoremIpsum url)


decodeLoremIpsum : Json.Decoder String
decodeLoremIpsum =
  Json.at [ "feed", "lipsum" ] Json.string

-- VIEW

view : Model -> Html Action
view model =
  div []
  [ div [class "well content direct", style containerStyles, onScroll Scroll] (map para model.items)
  ]

para : String -> Html Action
para content =
  p [] [text content]

onScroll : (Pos -> action) -> Attribute action
onScroll tagger =
  on "scroll" (Json.map tagger decodeScrollPosition)

decodeScrollPosition : Json.Decoder Pos
decodeScrollPosition =
  Json.object3 Pos
    (Json.at ["target", "scrollTop"] Json.int)
    (Json.at ["target", "scrollHeight"] Json.int)
    (Json.at ["target", "offsetHeight"] Json.int) -- TODO: should be max(offsetHeight, clientHeight)

containerStyles : List (String, String)
containerStyles =
  [("height", "700px")
  ,("width", "600px")
  ,("overflow", "auto")
  ,("border", "1px black solid")
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Action
subscriptions model =
  Sub.none

-- INIT

init : (Model, Cmd Action)
init =
  (Model [], fetchLoremIpsum 7 True)
