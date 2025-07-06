module Pages.Keys exposing (Msg(..), init, update, view)

import Html exposing (Html, div, button, text)
import Http
import Json.Decode as Decode


-- MODEL

type alias Model =
    { keys : List String
    , status : String
    }

init : ( Model, Cmd Msg )
init =
    ( { keys = [], status = "Loading..." }, getKeys )


-- UPDATE

type Msg
    = GotKeys (Result Http.Error (List String))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotKeys (Ok keyList) ->
            ( { model | keys = keyList, status = "Loaded." }, Cmd.none )

        GotKeys (Err err) ->
            ( { model | status = "Error: " ++ Debug.toString err }, Cmd.none )


-- HTTP

getKeys : Cmd Msg
getKeys =
    let
        decoder = Decode.field "keys" (Decode.list Decode.string)
    in
    Http.get
        { url = "/keys/list"
        , expect = Http.expectJson GotKeys decoder
        }


-- VIEW

view : Model -> Html Msg
view model =
    div []
        (text model.status :: List.map (\k -> div [] [ text k ]) model.keys)
