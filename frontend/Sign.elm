module Pages.Sign exposing (Msg(..), view, init, update)

import Browser.File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (for, id, type_)
import Html.Events exposing (onClick)
import Http
import Json.Encode as Encode
import File exposing (toBytes)


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
    | Upload
    | UploadResponse (Result Http.Error String)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected file ->
            ( { model | file = Just file }, Cmd.none )

        Upload ->
            case model.file of
                Just f ->
                    ( model
                    , toBytes f |> Task.attempt (Result.mapError (always Http.BadBody) >> UploadFile f)
                    )

                Nothing ->
                    ( { model | status = "No file selected." }, Cmd.none )

        UploadFile file (Ok bytes) ->
            let
                body = Http.multipartBody [ Http.filePart "file" file ]

                request =
                    Http.request
                        { method = "POST"
                        , headers = []
                        , url = "/sign"
                        , body = body
                        , expect = Http.expectString UploadResponse
                        , timeout = Nothing
                        , tracker = Nothing
                        }
            in
            ( model, Http.send UploadResponse request )

        UploadFile _ (Err _) ->
            ( { model | status = "Failed to read file." }, Cmd.none )

        UploadResponse (Ok msg) ->
            ( { model | status = "Success: " ++ msg }, Cmd.none )

        UploadResponse (Err err) ->
            ( { model | status = "Error: " ++ Debug.toString err }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ input [ type_ "file", id "file-upload", onClick (Select.file FileSelected) ] []
        , button [ onClick Upload ] [ text "Upload and Sign" ]
        , div [] [ text model.status ]
        ]
