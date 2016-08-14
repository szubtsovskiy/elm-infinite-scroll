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
  { scrolledHeight : Int
  , contentHeight : Int
  , containerHeight : Int
  }

type Action
  = FetchItems Int Bool
    | FetchSucceed (List String)
    | FetchFail Http.Error
    | Scroll Pos

-- UPDATE

-- TODO next: loading icon
-- TODO next: reversed version
-- TODO next: how to handle decoding errors (e.g. when field does not exist)
-- TODO next: tabbed component (new project)

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    FetchItems amount startWithLoremIpsum ->
      (model, fetchLoremIpsum amount startWithLoremIpsum)

    FetchSucceed items ->
      ({model | items = model.items ++ items}, Cmd.none)

    FetchFail err ->
      let
        _ =
          Debug.log "Error: " (toString err)
      in
        (model, Cmd.none)

    Scroll {scrolledHeight, contentHeight, containerHeight} ->
      let
        excessHeight = contentHeight - containerHeight
      in
        if scrolledHeight >= excessHeight then
          (model, fetchLoremIpsum 1 False)
        else
          (model, Cmd.none)


fetchLoremIpsum : Int -> Bool -> Cmd Action
fetchLoremIpsum amount startWithLoremIpsum =
  let
    url = "http://lipsum.com/feed/json?what=paras"
          ++ "&amount=" ++ (toString amount)
          ++ "&start=" ++ (if startWithLoremIpsum then "yes" else "no")
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeLoremIpsum url)


decodeLoremIpsum : Json.Decoder (List String)
decodeLoremIpsum =
  Json.object1 (split "\n") lipsum

lipsum : Json.Decoder String
lipsum =
  Json.at [ "feed", "lipsum" ] Json.string

-- VIEW

view : Model -> Html Action
view model =
  div []
  [ div [ class "well content direct", style containerStyles, onScroll Scroll ] (map para model.items)
  , div [ style loaderIconContainerStyles ]
    [ span [ class "fa fa-spinner fa-pulse fa-2x", style loaderIconStyles ] [ text " " ]
    ]
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
    scrollTop
    scrollHeight
    (maxInt offsetHeight clientHeight)

scrollTop : Json.Decoder Int
scrollTop =
  Json.at [ "target", "scrollTop" ] Json.int

scrollHeight : Json.Decoder Int
scrollHeight =
  Json.at [ "target", "scrollHeight" ] Json.int

offsetHeight : Json.Decoder Int
offsetHeight =
  Json.at [ "target", "offsetHeight" ] Json.int

clientHeight : Json.Decoder Int
clientHeight =
  Json.at [ "target", "clientHeight" ] Json.int

maxInt : Json.Decoder Int -> Json.Decoder Int -> Json.Decoder Int
maxInt x y =
  Json.object2 Basics.max x y

containerStyles : List (String, String)
containerStyles =
  [ ("height", "700px")
  , ("overflow", "auto")
  , ("border", "1px black solid")
  ]

loaderIconContainerStyles : List (String, String)
loaderIconContainerStyles =
  [ ("border", "1px blue solid")
  , ("height", "40px")
  , ("display", "flex")
  ]

loaderIconStyles : List (String, String)
loaderIconStyles =
  [ ("display", "flex")
  , ("margin", "auto")
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Action
subscriptions model =
  Sub.none

-- INIT

init : (Model, Cmd Action)
init =
  (Model [], fetchLoremIpsum 7 True)
