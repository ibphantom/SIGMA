module Pages.Encrypt exposing (Model, Msg(..), init, update, view)

import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


-- MODEL

type alias Model =
    { input : String
    , result : String
    , status : Maybe String
    , loading : Bool
    }

init : Model
init =
    { input = ""
    , result = ""
    , status = Nothing
    , loading = False
    }


-- MESSAGES

type Msg
    = InputChanged String
    | Submit
    | EncryptCompleted (Result Http.Error String)


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged str ->
            ( { model | input = str }, Cmd.none )

        Submit ->
            if String.isEmpty model.input then
                ( { model | status = Just "Input cannot be empty." }, Cmd.none )
            else
                ( { model | loading = True, status = Nothing }
                , encryptRequest model.input
                )

        EncryptCompleted result ->
            case result of
                Ok body ->
                    ( { model
                        | result = body
                        , loading = False
                        , status = Just "Encryption successful."
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | loading = False
                        , status = Just "Encryption failed. Please try again."
                      }
                    , Cmd.none
                    )


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "encrypt-page" ]
        [ h2 [] [ text "Encrypt Message" ]
        , textarea
            [ placeholder "Enter your message here..."
            , value model.input
            , onInput InputChanged
            ]
            []
        , button
            [ onClick Submit, disabled model.loading ]
            [ text (if model.loading then "Encrypting..." else "Encrypt") ]
        , case model.status of
            Just msg ->
                div [ class "status" ] [ text msg ]

            Nothing ->
                text ""
        , if not (String.isEmpty model.result) then
            div [ class "result" ]
                [ h3 [] [ text "Encrypted Output" ]
                , pre [] [ text model.result ]
                ]
          else
            text ""
        ]


-- HTTP

encryptRequest : String -> Cmd Msg
encryptRequest message =
    let
        body =
            Encode.object [ ( "message", Encode.string message ) ]
    in
    Http.post
        { url = "/api/encrypt"
        , body = Http.jsonBody body
        , expect = Http.expectString EncryptCompleted
        }
