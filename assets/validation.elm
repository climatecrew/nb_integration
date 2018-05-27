module Validation exposing (..)

import Date exposing (Date)
import Result exposing (Result, andThen)
import Types exposing (..)
import Utilities exposing (..)


showValidationErrors : Model -> ShowValidationErrors
showValidationErrors model =
    { showEventNameErrors = not <| eventNamePresent model
    , showContactNameErrors = not <| contactNamePresent model
    , showContactEmailErrors = not <| contactEmailPresent model
    , showDateErrors = not <| datesOk model
    , showVenueNameErrors = not <| venueNamePresent model
    , showStreetAddressErrors = not <| streetAddressPresent model
    , showCityErrors = not <| cityPresent model
    , showStateErrors = not <| statePresent model
    }


showDateError : ShowValidationErrors -> Bool -> ShowValidationErrors
showDateError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showDateErrors = True }
    else
        { validationErrors | showDateErrors = False }


showEventNameError : ShowValidationErrors -> Bool -> ShowValidationErrors
showEventNameError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showEventNameErrors = True }
    else
        { validationErrors | showEventNameErrors = False }


showContactNameError : ShowValidationErrors -> Bool -> ShowValidationErrors
showContactNameError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showContactNameErrors = True }
    else
        { validationErrors | showContactNameErrors = False }


showContactEmailError : ShowValidationErrors -> Bool -> ShowValidationErrors
showContactEmailError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showContactEmailErrors = True }
    else
        { validationErrors | showContactEmailErrors = False }


showVenueNameError : ShowValidationErrors -> Bool -> ShowValidationErrors
showVenueNameError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showVenueNameErrors = True }
    else
        { validationErrors | showVenueNameErrors = False }


showStreetAddressError : ShowValidationErrors -> Bool -> ShowValidationErrors
showStreetAddressError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showStreetAddressErrors = True }
    else
        { validationErrors | showStreetAddressErrors = False }


showCityError : ShowValidationErrors -> Bool -> ShowValidationErrors
showCityError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showCityErrors = True }
    else
        { validationErrors | showCityErrors = False }


showStateError : ShowValidationErrors -> Bool -> ShowValidationErrors
showStateError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showStateErrors = True }
    else
        { validationErrors | showStateErrors = False }


eventNamePresent : Model -> Bool
eventNamePresent model =
    String.length model.event.name > 0


eventVenueName : Model -> Maybe String
eventVenueName model =
    model.event.venue.name


eventAddress : Model -> Maybe Address
eventAddress model =
    model.event.venue.address


streetAddressPresent : Model -> Bool
streetAddressPresent model =
    String.length
        (Maybe.withDefault "" (eventAddress model |> Maybe.andThen .address1))
        > 0


venueNamePresent : Model -> Bool
venueNamePresent model =
    String.length (Maybe.withDefault "" <| eventVenueName model) > 0


cityPresent : Model -> Bool
cityPresent model =
    String.length
        (Maybe.withDefault "" (eventAddress model |> Maybe.andThen .city))
        > 0


statePresent : Model -> Bool
statePresent model =
    String.length
        (Maybe.withDefault "" (eventAddress model |> Maybe.andThen .state))
        > 0


contactNamePresent : Model -> Bool
contactNamePresent model =
    String.length (Maybe.withDefault "" model.event.contact.name) > 0


contactEmailPresent : Model -> Bool
contactEmailPresent model =
    String.length (Maybe.withDefault "" model.event.contact.email) > 0


invalidInput : Model -> Bool
invalidInput model =
    not <|
        List.all identity
            [ datesOk model
            , contactNamePresent model
            , contactEmailPresent model
            , eventNamePresent model
            , venueNamePresent model
            , streetAddressPresent model
            , cityPresent model
            , statePresent model
            ]


datesOk : Model -> Bool
datesOk model =
    let
        dates =
            andThen (secondDate model.event.endTimestamp) (asDate model.event.startTimestamp)
    in
        case dates of
            Ok ( sd, ed ) ->
                lessThan ( sd, ed )

            Err _ ->
                False


lessThan : ( Date, Date ) -> Bool
lessThan ( d1, d2 ) =
    Date.toTime d1 < Date.toTime d2


asDate : EditingTimestamp -> Result String Date
asDate et =
    Date.fromString (serializeTimestamp et)


secondDate : EditingTimestamp -> Date -> Result String ( Date, Date )
secondDate et firstDate =
    case asDate et of
        Ok date ->
            Ok ( firstDate, date )

        Err err ->
            Err err
