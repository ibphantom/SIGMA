module Pages.Encrypt exposing (view)

import Html exposing (Html, div, input, button, label, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import File exposing (File)
import File.Select as Select


type alias Model =
    { selectedFile : Maybe File
    , recipient : String
    , status : Status
    }


type Status
    = Idle
    | Encrypting
    | Success
    | Failure String


type Msg
    = SelectFile
    | FileSelected File
    | RecipientChanged String
    | Submit
    | EncryptionResult (Result String ())


view : Html Msg
view =
    Html.map identity <|
        viewInternal { selectedFile = Nothing, recipient = "", status = Idle }


viewInternal : Model -> Html Msg
viewInternal model =
    div [ class "encrypt-page" ]
        [ label [] [ text "Recipient Key ID or Email:" ]
        , input [ type_ "text", placeholder "key-id or email", onInput RecipientChanged ] []
        , button [ onClick SelectFile ] [ text "Choose File" ]
        , button [ onClick Submit ] [ text "Encrypt" ]
        , viewStatus model.status
        ]


viewStatus : Status -> Html msg
viewStatus status =
    case status of
        Idle ->
            text ""

        Encrypting ->
            div [ class "status encrypting" ] [ text "Encrypting..." ]

        Success ->
            div [ class "status success" ] [ text "Encrypted successfully!" ]

        Failure err ->
            div [ class "status error" ] [ text ("Error: " ++ err) ]
