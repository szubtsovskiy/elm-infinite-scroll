module LoremIpsum exposing (Action, fetch, receive)
import Http
import Task
import Json.Decode as Json
import String exposing (split)

type Action
  = FetchFail Http.Error
  | FetchSucceed (List String)

receive : Action -> Maybe (List String)
receive action =
  case action of
    FetchSucceed items ->
      Just items

    FetchFail err ->
      let
        _ =
          Debug.log "Error: " (toString err)
      in
        Nothing

fetch : Int -> Bool -> Cmd Action
fetch amount startWithLoremIpsum =
  let
    startParam = if startWithLoremIpsum then "yes" else "no"
    url = "http://lipsum.com/feed/json?what=paras"
          ++ "&amount=" ++ (toString amount)
          ++ "&start=" ++ startParam
  in
    Task.perform FetchFail FetchSucceed (Http.get decode url)

decode : Json.Decoder (List String)
decode =
  Json.object1 (split "\n") lipsum

lipsum : Json.Decoder String
lipsum =
  Json.at [ "feed", "lipsum" ] Json.string
