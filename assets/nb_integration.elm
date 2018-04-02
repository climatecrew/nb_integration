module Main exposing (..)

import Html exposing (programWithFlags, div, button, text)
import Html.Events exposing (onClick)


main =
    programWithFlags { init = init, update = update, subscriptions = subscriptions, view = view }


init : Flags -> ( Model, Cmd msg )
init flags =
    ( model, Cmd.none )


model =
    0


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (toString model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]


type Msg
    = Increment
    | Decrement


type alias Model =
    Int


type alias Flags =
    String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )
