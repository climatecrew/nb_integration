module Main exposing (main, subscriptions)

import Browser
import ContactMe


main : Program ContactMe.Flags ContactMe.Model ContactMe.Msg
main =
    Browser.element
        { init = ContactMe.init
        , update = ContactMe.update
        , subscriptions = subscriptions
        , view = ContactMe.view
        }


subscriptions : ContactMe.Model -> Sub ContactMe.Msg
subscriptions model =
    ContactMe.subscriptions model
