module Validation exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)
import Result exposing (Result, andThen)
import Utilities exposing (..)
import Types exposing (Model, ValidationErrors, Address)
import EditingTimestamp exposing (EditingTimestamp)


showValidationErrors : Model -> ValidationErrors
showValidationErrors model =
    Dict.fromList
        [ ( "event.name", not <| eventNamePresent model )
        , ( "contact.name", not <| contactNamePresent model )
        , ( "contact.email", not <| contactEmailPresent model )
        , ( "date", not <| datesOk model )
        , ( "venue.name", not <| venueNamePresent model )
        , ( "venue.street_address", not <| streetAddressPresent model )
        , ( "venue.city", not <| cityPresent model )
        , ( "venue.state", not <| statePresent model )
        ]


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
