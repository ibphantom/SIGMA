module Pages.Keys exposing (view)

import Html exposing (Html, div, button, ul, li, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type alias Model =
    { keys : List String
    , status : Status
    }


type Status
    = Idle
    | Loading
    | Loaded (List String)
    | Error String


type Msg
    = FetchKeys
    | KeysFetched (Result String (List String))


view : Html Msg
view =
    Html.map identity <|
        viewInternal { keys = [], status = Idle }


viewInternal : Model -> Html Msg
viewInternal model =
    div [ class "keys-page" ]
        [ button [ onClick FetchKeys ] [ text "List Local Keys" ]
        , viewStatus model.status
        ]


viewStatus : Status -> Html msg
viewStatus status =
    case status of
        Idle ->
            text ""

        Loading ->
            div [ class "status loading" ] [ text "Loading..." ]

        Loaded keys ->
            ul [] (List.map (\k -> li [] [ text k ]) keys)

        Error err ->
            div [ class "status error" ] [ text ("Error: " ++ err) ]
