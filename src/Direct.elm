module Direct exposing (main)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick)
import Random

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model =
  { dieFace : Int
  }

type Action
  = Roll
  | NewFace Int

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    Roll ->
      (model, Random.generate NewFace (Random.int 1 6))
    NewFace face ->
      ({ model | dieFace = face }, Cmd.none)

view : Model -> Html Action
view model =
  div []
  [ h1 [] [ text(toString model.dieFace) ]
  , button [ onClick Roll ]  [ text "Roll" ]
  ]

subscriptions : Model -> Sub Action
subscriptions model =
  Sub.none

init : (Model, Cmd Action)
init =
  (Model 1, Cmd.none)
