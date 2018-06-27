module Main exposing (..)

import Html exposing (programWithFlags)
import ContactMe


main : Program ContactMe.Flags ContactMe.Model ContactMe.Msg
main =
    programWithFlags
        { init = ContactMe.init
        , update = ContactMe.update
        , subscriptions = subscriptions
        , view = ContactMe.view
        }


subscriptions : ContactMe.Model -> Sub msg
subscriptions model =
    Sub.none
