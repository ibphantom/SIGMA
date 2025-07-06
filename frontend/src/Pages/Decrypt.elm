module Pages.Decrypt exposing (view)

import Html exposing (Html, div, button, label, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import File exposing (File)
import File.Select as Select


type alias Model =
    { selectedFile : Maybe File
    , status : Status
    }


type Status
    = Idle
    | Decrypting
    | Success String
    | Failure String


type Msg
    = SelectFile
    | FileSelected File
    | Submit
    | DecryptionResult (Result String String)


view : Html Msg
view =
    Html.map identity <|
        viewInternal { selectedFile = Nothing, status = Idle }


viewInternal : Model -> Html Msg
viewInternal model =
    div [ class "decrypt-page" ]
        [ label [] [ text "Select Encrypted File:" ]
        , button [ onClick SelectFile ] [ text "Choose File" ]
        , button [ onClick Submit ] [ text "Decrypt" ]
        , viewStatus model.status
        ]


viewStatus : Status -> Html msg
viewStatus status =
    case status of
        Idle ->
            text ""

        Decrypting ->
            div [ class "status decrypting" ] [ text "Decrypting..." ]

        Success msg ->
            div [ class "status success" ] [ text ("Decrypted: " ++ msg) ]

        Failure err ->
            div [ class "status error" ] [ text ("Error: " ++ err) ]
