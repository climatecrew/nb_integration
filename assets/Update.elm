module Update exposing (..)

import Types exposing (..)


updateModelEvent : Model -> Event -> Model
updateModelEvent model newEvent =
    { model | event = newEvent }


updateEventName : Model -> String -> Model
updateEventName model name =
    let
        { event } =
            model

        newEvent =
            { event | name = name }
    in
        { model | event = newEvent }
