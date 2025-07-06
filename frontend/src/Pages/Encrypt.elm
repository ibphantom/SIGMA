module Pages.Encrypt exposing (Msg(..), init, update, view)

import Browser.File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (type_)
import Html.Events exposing (onClick)
import Http


-- MODEL

type alias Model =
    { file : Maybe File
    , status : String
    }

init : ( Model, Cmd Msg )
init =
    ( { file = Nothing, status = "" }
    , Cmd.none
    )


-- UPDATE

type Msg
    = FileSelected File
    | Submit
    | UploadResponse (Result Http.Error String)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected file ->
            ( { model | file = Just file }, Cmd.none )

        Submit ->
            case model.file of
                Just f ->
                    let
                        body = Http.multipartBody [ Http.filePart "file" f ]
                        request =
                            Http.request
                                { method = "POST"
                                , headers = []
                                , url = "/encrypt"
                                , body = body
                                , expect = Http.expectString UploadResponse
                                , timeout = Nothing
                                , tracker = Nothing
                                }
                    in
                    ( model, Http.send UploadResponse request )

                Nothing ->
                    ( { model | status = "Please select a file." }, Cmd.none )

        UploadResponse (Ok msg) ->
            ( { model | status = "Encrypted: " ++ msg }, Cmd.none )

        UploadResponse (Err err) ->
            ( { model | status = "Error: " ++ Debug.toString err }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ input [ type_ "file", onClick (Select.file FileSelected) ] []
        , button [ onClick Submit ] [ text "Encrypt" ]
        , div [] [ text model.status ]
        ]
