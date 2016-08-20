module Reversed exposing (main)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick, on)
import Html.Attributes exposing (..)
import Platform exposing (Program)
import Json.Decode as Json
import List exposing (map)
import AjaxLoader
import Helpers.LoremIpsum as LoremIpsum
import Dom
import Dom.Scroll
import Task

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
  | Scroll Int
  | LoaderNoOp AjaxLoader.Action
  | DomError Dom.Error
  | DomNoOp ()

-- UPDATE

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    Scroll scrolledHeight ->
      if scrolledHeight == 0 then
        ({ model | loader = AjaxLoader.show model.loader }, Cmd.map ReceiveLoremIpsum (LoremIpsum.fetch 1 False))
      else
        (model, Cmd.none)

    ReceiveLoremIpsum action ->
      let
        loader = AjaxLoader.hide model.loader
      in
        case LoremIpsum.receive action of
          Just items ->
            ({model | items = items ++ model.items, loader = loader }, Task.perform DomError DomNoOp (Dom.Scroll.toY "reversed-container" 40))

          Nothing ->
            ({model | loader = loader }, Cmd.none)

    LoaderNoOp _ ->
      (model, Cmd.none)

    DomError err ->
      let
        _ = Debug.log "DOM error: " (toString err)
      in
        (model, Cmd.none)

    DomNoOp _ ->
      (model, Cmd.none)


-- VIEW

view : Model -> Html Action
view model =
  let
    paras = map para model.items
    loader = App.map LoaderNoOp (AjaxLoader.view model.loader)
    styles = model.styles
  in
    div []
    [ div [ id "reversed-container", class styles.container, onScroll Scroll ] ([loader] ++ paras)
    ]

para : String -> Html Action
para content =
  p [] [text content]

onScroll : (Int -> action) -> Attribute action
onScroll tagger =
  on "scroll" (Json.map tagger scrollTop)

scrollTop : Json.Decoder Int
scrollTop =
  Json.at [ "target", "scrollTop" ] Json.int

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
