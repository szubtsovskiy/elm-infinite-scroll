module Direct exposing (main)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick)
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

type Action
  = FetchItems Int Bool
    | FetchSucceed String
    | FetchFail Http.Error

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
  [ div [class "well content direct", style containerStyles] (map htmlP model.items)
  ]

htmlP : String -> Html Action
htmlP content =
  p [] [text content]

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
