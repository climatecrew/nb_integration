module Main exposing (..)

import Html exposing (programWithFlags)
import Types exposing (Model, Msg, Flags)
import EventCreator


main : Program Flags Model Msg
main =
    programWithFlags
        { init = EventCreator.init
        , update = EventCreator.update
        , subscriptions = subscriptions
        , view = EventCreator.view
        }


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none
