module Helpers.LoremIpsum exposing (Msg, fetch, receive)
import Http
import Task
import Json.Decode as Json
import String exposing (split)

type Msg
  = OnFetch (Result Http.Error (List String))

receive : Msg -> Maybe (List String)
receive msg =
  case msg of
    OnFetch result ->
      case result of
        Ok items ->
          Just items

        Err err ->
          let
            _ =
              Debug.log "Error: " (toString err)
          in
            Nothing

fetch : Int -> Bool -> Cmd Msg
fetch amount startWithLoremIpsum =
  let
    startParam = if startWithLoremIpsum then "yes" else "no"
    url = "http://lipsum.com/feed/json?what=paras"
          ++ "&amount=" ++ (toString amount)
          ++ "&start=" ++ startParam
  in
    Http.get url loremIpsum
      |> Http.send OnFetch

loremIpsum : Json.Decoder (List String)
loremIpsum =
  Json.map (split "\n") <| Json.at [ "feed", "lipsum" ] Json.string

