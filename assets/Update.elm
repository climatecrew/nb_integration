module Update exposing (..)

import Types exposing (..)
import EditingTimestamp exposing (EditingTimestamp, BorderTime, startTime, endTime)
import Validation
    exposing
        ( setValid
        , touchValidation
        , contactNamePresent
        , contactEmailPresent
        , datesOk
        , eventNamePresent
        , venueNamePresent
        , streetAddressPresent
        , cityPresent
        , statePresent
        )


updateContactName : Model -> Maybe String -> Model
updateContactName model name =
    let
        { contact } =
            model

        newContact =
            { contact | name = name }

        newModel =
            let
                m =
                    { model | contact = newContact }
            in
                touchValidation m "contact.name" <| contactNamePresent m
    in
        newModel


updateContactEmail : Model -> Maybe String -> Model
updateContactEmail model email =
    let
        { contact } =
            model

        newContact =
            { contact | email = email }

        newModel =
            let
                m =
                    { model | contact = newContact }
            in
                touchValidation m "contact.email" <| contactEmailPresent m
    in
        newModel


updateEvent : Model -> Event -> Model
updateEvent model newEvent =
    { model | event = newEvent }


updateEventDay : Model -> String -> Model
updateEventDay model ymd =
    let
        { event } =
            model

        { startTimestamp, endTimestamp } =
            event

        updatedStartTS =
            { startTimestamp | ymd = ymd }

        updatedEndTS =
            { endTimestamp | ymd = ymd }
    in
        updateEvent model
            { event | startTimestamp = updatedStartTS, endTimestamp = updatedEndTS }


updateEventHour : Model -> BorderTime -> String -> Model
updateEventHour model borderTime hour =
    let
        { event } =
            model

        updatedEvent =
            let
                currentTS =
                    extractTimestamp event borderTime

                updatedTS =
                    let
                        updatedHour =
                            case String.toInt hour of
                                Ok hr ->
                                    hr

                                Err err ->
                                    currentTS.hour
                    in
                        { currentTS | hour = updatedHour }
            in
                updateTimestamp event borderTime updatedTS

        um1 =
            updateEvent model updatedEvent

        updatedModel =
            touchValidation um1 "date" (datesOk um1)
    in
        updatedModel


extractTimestamp : Event -> BorderTime -> EditingTimestamp
extractTimestamp event borderTime =
    if borderTime == startTime then
        event.startTimestamp
    else
        event.endTimestamp


updateTimestamp : Event -> BorderTime -> EditingTimestamp -> Event
updateTimestamp event borderTime timestamp =
    if borderTime == startTime then
        { event | startTimestamp = timestamp }
    else
        { event | endTimestamp = timestamp }


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
                touchValidation m "event.name" <| eventNamePresent m
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

        newModel =
            updateEventVenue model newVenue
    in
        newModel


updateEventVenueStreetAddress : Model -> Maybe String -> Model
updateEventVenueStreetAddress model streetAddress =
    let
        address =
            startingAddress model

        newAddress =
            { address | address1 = streetAddress }

        m0 =
            updateEventVenueAddress model <| Just newAddress

        newModel =
            touchValidation m0 "venue.street_address" <| streetAddressPresent m0
    in
        newModel


updateEventVenueCity : Model -> Maybe String -> Model
updateEventVenueCity model city =
    let
        address =
            startingAddress model

        newAddress =
            { address | city = city }

        m0 =
            updateEventVenueAddress model <| Just newAddress

        newModel =
            touchValidation m0 "venue.city" <| cityPresent m0
    in
        newModel


updateEventVenueState : Model -> Maybe String -> Model
updateEventVenueState model state =
    let
        address =
            startingAddress model

        newAddress =
            { address | state = state }

        m0 =
            updateEventVenueAddress model <| Just newAddress

        newModel =
            touchValidation m0 "venue.state" <| statePresent m0
    in
        newModel


startingAddress : Model -> Address
startingAddress model =
    let
        { venue } =
            model.event

        { address } =
            venue
    in
        Maybe.withDefault defaultAddress address
