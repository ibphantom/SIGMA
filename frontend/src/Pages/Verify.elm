module Pages.Verify exposing (view)

import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import File exposing (File)
import File.Select as Select


type alias Model =
    { mediaFile : Maybe File
    , signatureFile : Maybe File
    , status : Status
    }


type Status
    = Idle
    | Verifying
    | Valid
    | Invalid
    | Error String


type Msg
    = SelectMedia
    | SelectSignature
    | FileSelectedMedia File
    | FileSelectedSignature File
    | Submit
    | VerificationComplete (Result String Bool)


view : Html Msg
view =
    Html.map identity <|
        viewInternal { mediaFile = Nothing, signatureFile = Nothing, status = Idle }


viewInternal : Model -> Html Msg
viewInternal model =
    div [ class "verify-page" ]
        [ label [] [ text "Select Media File:" ]
        , button [ onClick SelectMedia ] [ text "Choose Media" ]
        , label [] [ text "Select Signature File:" ]
        , button [ onClick SelectSignature ] [ text "Choose .sig" ]
        , button [ onClick Submit ] [ text "Verify" ]
        , viewStatus model.status
        ]


viewStatus : Status -> Html msg
viewStatus status =
    case status of
        Idle ->
            text ""

        Verifying ->
            div [ class "status verifying" ] [ text "Verifying..." ]

        Valid ->
            div [ class "status valid" ] [ text "Signature is VALID ✅" ]

        Invalid ->
            div [ class "status invalid" ] [ text "Signature is INVALID ❌" ]

        Error msg ->
            div [ class "status error" ] [ text ("Error: " ++ msg) ]
