module Update exposing (..)

import Types exposing (..)
import Validation exposing (setError, touchValidation, eventNamePresent, venueNamePresent, streetAddressPresent, cityPresent, statePresent)


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
                touchValidation m "venue.name" (venueNamePresent m)
    in
        newModel


updateEventVenueAddress : Model -> Maybe Address -> Model
updateEventVenueAddress model address =
    let
        { venue } =
            model.event

        newVenue =
            { venue | address = address }

        m0 =
            updateEventVenue model newVenue

        m1 =
            setError m0 "venue.street_address" (not <| streetAddressPresent m0)

        m2 =
            setError m1 "venue.city" (not <| cityPresent m1)

        newModel =
            setError m2 "venue.state" (not <| statePresent m2)
    in
        newModel


updateEventVenueStreetAddress : Model -> Maybe String -> Model
updateEventVenueStreetAddress model streetAddress =
    let
        address =
            startingAddress model

        newAddress =
            { address | address1 = streetAddress }
    in
        updateEventVenueAddress model <| Just newAddress


updateEventVenueCity : Model -> Maybe String -> Model
updateEventVenueCity model city =
    let
        address =
            startingAddress model

        newAddress =
            { address | city = city }
    in
        updateEventVenueAddress model <| Just newAddress


updateEventVenueState : Model -> Maybe String -> Model
updateEventVenueState model state =
    let
        address =
            startingAddress model

        newAddress =
            { address | state = state }
    in
        updateEventVenueAddress model <| Just newAddress


startingAddress : Model -> Address
startingAddress model =
    let
        { venue } =
            model.event

        { address } =
            venue
    in
        Maybe.withDefault defaultAddress address
