module Direct exposing (main)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Random

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
  = FetchOne

-- UPDATE

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    FetchOne ->
      (model, Cmd.none)

-- VIEW

view : Model -> Html Action
view model =
  div []
  [ div [class "well content direct", style containerStyles] []
  ]

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
  (Model [], Cmd.none)
