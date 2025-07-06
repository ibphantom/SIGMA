module Pages.Verify exposing (Msg(..), init, update, view)

import Browser.File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (type_)
import Html.Events exposing (onClick)
import Http
import Json.Encode
import File exposing (toBytes)
import Task


-- MODEL

type alias Model =
    { file : Maybe File
    , sig : Maybe File
    , status : String
    }

init : ( Model, Cmd Msg )
init =
    ( { file = Nothing, sig = Nothing, status = "" }
    , Cmd.none
    )


-- UPDATE

type Msg
    = FileSelected File
    | SigSelected File
    | Submit
    | UploadResponse (Result Http.Error String)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected file ->
            ( { model | file = Just file }, Cmd.none )

        SigSelected sig ->
            ( { model | sig = Just sig }, Cmd.none )

        Submit ->
            case ( model.file, model.sig ) of
                ( Just f, Just s ) ->
                    let
                        body =
                            Http.multipartBody
                                [ Http.filePart "file" f
                                , Http.filePart "signature" s
                                ]

                        request =
                            Http.request
                                { method = "POST"
                                , headers = []
                                , url = "/verify"
                                , body = body
                                , expect = Http.expectString UploadResponse
                                , timeout = Nothing
                                , tracker = Nothing
                                }
                    in
                    ( model, Http.send UploadResponse request )

                _ ->
                    ( { model | status = "Missing file or signature." }, Cmd.none )

        UploadResponse (Ok msg) ->
            ( { model | status = "Success: " ++ msg }, Cmd.none )

        UploadResponse (Err err) ->
            ( { model | status = "Error: " ++ Debug.toString err }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ input [ type_ "file", onClick (Select.file FileSelected) ] []
        , input [ type_ "file", onClick (Select.file SigSelected) ] []
        , button [ onClick Submit ] [ text "Verify" ]
        , div [] [ text model.status ]
        ]
