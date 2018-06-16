module Update exposing (..)

import Types exposing (..)
import Validation exposing (eventNamePresent, venueNamePresent)


updateEvent : Model -> Event -> Model
updateEvent model newEvent =
    { model | event = newEvent }


updateEventName : Model -> String -> Model
updateEventName model name =
    let
        { event } =
            model

        newModel =
            let
                m =
                    updateEvent model { event | name = name }
            in
                setError m "event.name" (not <| eventNamePresent m)
    in
        newModel


updateEventIntro : Model -> String -> Model
updateEventIntro model intro =
    let
        { event } =
            model
    in
        updateEvent model { event | intro = intro }


updateEventVenue : Model -> Venue -> Model
updateEventVenue model venue =
    let
        { event } =
            model

        newEvent =
            { event | venue = venue }
    in
        { model | event = newEvent }


updateEventVenueName : Model -> Maybe String -> Model
updateEventVenueName model name =
    let
        { venue } =
            model.event

        newVenue =
            { venue | name = name }

        newModel =
            let
                m =
                    updateEventVenue model newVenue
            in
                setError m "venue.name" (not <| venueNamePresent m)
    in
        newModel
