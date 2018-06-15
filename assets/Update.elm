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

        newModel =
            let
                m =
                    updateModelEvent model { event | name = name }
            in
                setError m "event.name" (String.length name == 0)
    in
        newModel
