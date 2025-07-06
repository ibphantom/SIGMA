module Pages.Sign exposing (view)

import Browser.Dom
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import File exposing (File)
import File.Select as Select


type alias Model =
    { selectedFile : Maybe File
    , status : Status
    }


type Status
    = Idle
    | Uploading
    | Success String
    | Failure String


type Msg
    = SelectFile
    | FileSelected File
    | Submit
    | UploadComplete (Result Http.Error String)


view : Html Msg
view =
    Html.map identity <|
        viewInternal { selectedFile = Nothing, status = Idle }


viewInternal : Model -> Html Msg
viewInternal model =
    div [ class "sign-page" ]
        [ label [] [ text "Select a file to sign:" ]
        , button [ onClick SelectFile ] [ text "Choose File" ]
        , input [ type_ "file", style "display" "none", id "fileInput", onInput (\_ -> Submit) ] []
        , button [ onClick Submit ] [ text "Sign" ]
        , viewStatus model.status
        ]


viewStatus : Status -> Html msg
viewStatus status =
    case status of
        Idle ->
            text ""

        Uploading ->
            div [ class "status uploading" ] [ text "Signing..." ]

        Success link ->
            div [ class "status success" ]
                [ text "Signed successfully. "
                , Html.a [ href link, download "signature.sig" ] [ text "Download .sig" ]
                ]

        Failure err ->
            div [ class "status error" ] [ text ("Error: " ++ err) ]
