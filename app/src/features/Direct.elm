module Direct exposing (main)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick, on)
import Html.Attributes exposing (..)
import Platform exposing (Program)
import Json.Decode as Json
import List exposing (map)
import AjaxLoader
import LoremIpsum

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
  = ReceiveLoremIpsum LoremIpsum.Action
  | Scroll Pos
  | LoaderNoOp AjaxLoader.Action

-- UPDATE

-- TODO next: reversed version
-- TODO next: how to handle decoding errors (e.g. when field does not exist)

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    Scroll {scrolledHeight, contentHeight, containerHeight} ->
      let
        excessHeight = contentHeight - containerHeight
      in
        if scrolledHeight >= excessHeight then
          ({ model | loader = AjaxLoader.show model.loader }, Cmd.map ReceiveLoremIpsum (LoremIpsum.fetch 1 False))
        else
          (model, Cmd.none)

    LoaderNoOp _ ->
      (model, Cmd.none)

    ReceiveLoremIpsum action ->
      let
        loader = AjaxLoader.hide model.loader
      in
        case LoremIpsum.receive action of
          Just items ->
            ({model | items = model.items ++ items, loader = loader }, Cmd.none)

          Nothing ->
            ({model | loader = loader }, Cmd.none)


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
    (model, Cmd.map ReceiveLoremIpsum (LoremIpsum.fetch 17 True))
