module Pages.Keys exposing (Msg(..), init, update, view)

import Browser.File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode


-- MODEL

type alias Model =
    { keys : List String
    , status : String
    , file : Maybe File
    }

init : ( Model, Cmd Msg )
init =
    ( { keys = [], status = "Loading...", file = Nothing }, getKeys )


-- UPDATE

type Msg
    = GotKeys (Result Http.Error (List String))
    | FileSelected File
    | Submit
    | UploadResponse (Result Http.Error String)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotKeys (Ok keyList) ->
            ( { model | keys = keyList, status = "Loaded." }, Cmd.none )

        GotKeys (Err err) ->
            ( { model | status = "Error: " ++ Debug.toString err }, Cmd.none )

        FileSelected file ->
            ( { model | file = Just file }, Cmd.none )

        Submit ->
            case model.file of
                Just f ->
                    let
                        body = Http.multipartBody [ Http.filePart "key" f ]
                        request =
                            Http.request
                                { method = "POST"
                                , headers = []
                                , url = "/keys/import"
                                , body = body
                                , expect = Http.expectString UploadResponse
                                , timeout = Nothing
                                , tracker = Nothing
                                }
                    in
                    ( model, Http.send UploadResponse request )

                Nothing ->
                    ( { model | status = "Please select a key file." }, Cmd.none )

        UploadResponse (Ok msg) ->
            ( { model | status = "Uploaded: " ++ msg }, getKeys )

        UploadResponse (Err err) ->
            ( { model | status = "Upload error: " ++ Debug.toString err }, Cmd.none )


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
        ([ input [ type_ "file", onClick (Select.file FileSelected) ] []
         , button [ onClick Submit ] [ text "Upload Key" ]
         , div [] [ text model.status ]
         ] ++ List.map (\k -> div [] [ text k ]) model.keys)
