module AjaxLoader exposing (Model, Action, init, show, hide, view)
import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (..)

main = App.beginnerProgram { model = init True, view = view, update = update }

-- MODEL

type alias Model =
  { visible : Bool
  }

type Action
  = Show
  | Hide

-- UPDATE

update : Action -> Model -> Model
update action model =
  case action of
    Show ->
      { model | visible = True }

    Hide ->
      { model | visible = False }


show : Model -> Model
show model =
  update Show model


hide : Model -> Model
hide model =
  update Hide model

-- VIEW

view : Model -> Html Action
view model =
  div [ style (loaderIconContainerStyles model.visible) ]
  [ span [ class "fa fa-spinner fa-pulse fa-2x", style loaderIconStyles ] [ text " " ]
  ]


loaderIconContainerStyles visible =
  [ ("height", "40px")
  , ("display", if visible then "flex" else "none")
  ]


loaderIconStyles : List (String, String)
loaderIconStyles =
  [ ("display", "flex")
  , ("margin", "auto")
  ]

-- INIT

init : Bool -> Model
init visible =
  Model visible