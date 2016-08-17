module Direct exposing (main)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick, on)
import Html.Attributes exposing (..)
import Http
import Task
import Platform exposing (Program)
import Json.Decode as Json
import String exposing (split)
import List exposing (map)
import AjaxLoader

main : Program Styles
main =
  App.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Styles =
  { container : String
  , loaderIconContainer : String
  , loaderIcon : String
  }

type alias Model =
  { items : List String
  , loader : AjaxLoader.Model
  , styles : Styles
  }

type alias Pos =
  { scrolledHeight : Int
  , contentHeight : Int
  , containerHeight : Int
  }

type Action
  = FetchSucceed (List String)
  | FetchFail Http.Error
  | Scroll Pos
  | LoaderNoOp AjaxLoader.Action

-- UPDATE

-- TODO next: reversed version
-- TODO next: how to handle decoding errors (e.g. when field does not exist)
-- TODO next: tabbed component (new project)

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    FetchSucceed items ->
      ({ model | items = model.items ++ items, loader = AjaxLoader.hide model.loader }, Cmd.none)

    FetchFail err ->
      let
        _ =
          Debug.log "Error: " (toString err)
      in
        ({ model | loader = AjaxLoader.hide model.loader }, Cmd.none)

    Scroll {scrolledHeight, contentHeight, containerHeight} ->
      let
        excessHeight = contentHeight - containerHeight
      in
        if scrolledHeight >= excessHeight then
          ({ model | loader = AjaxLoader.show model.loader }, fetchLoremIpsum 1 False)
        else
          (model, Cmd.none)

    LoaderNoOp _ ->
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
  let
    paras = map para model.items
    loader = App.map LoaderNoOp (AjaxLoader.view model.loader)
    styles = model.styles
  in
    div []
    [ div [ class styles.container, onScroll Scroll ] (paras ++ [loader])
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

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Action
subscriptions model =
  Sub.none

-- INIT

init : Styles -> (Model, Cmd Action)
init styles =
  let
    model =
      { items = []
      , loader = AjaxLoader.init True (AjaxLoader.Styles styles.loaderIconContainer styles.loaderIcon)
      , styles = styles
      }
  in
    (model, fetchLoremIpsum 17 True)
