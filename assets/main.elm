module Main exposing (..)

import Html exposing (Html, programWithFlags)
import Http exposing (jsonBody)
import Json.Decode as JD exposing (field, dict, list, string, array, int, oneOf, decodeString, succeed, nullable)
import Json.Encode as JE exposing (Value, encode, object)
import Types exposing (..)
import Views exposing (..)
import Utilities exposing (..)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            defaultModel flags
    in
        ( model, Http.send FetchEventsResult (getEvents model) )


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    mainView model


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EventName name ->
            let
                updatedErrors =
                    showEventNameError model.validationErrors (String.length name == 0)

                ev =
                    model.event

                updatedEvent =
                    { ev | name = name }
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        EventIntro intro ->
            let
                ev =
                    model.event

                updatedEvent =
                    { ev | intro = intro }
            in
                ( { model | event = updatedEvent }, Cmd.none )

        EventVenueAddress1 address1 ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentVenue =
                            ev.venue

                        currentAddress =
                            currentVenue.address

                        updatedAddress =
                            case currentAddress of
                                Just address ->
                                    Just { address | address1 = Just address1 }

                                Nothing ->
                                    Just { defaultAddress | address1 = Just address1 }

                        updatedVenue =
                            { currentVenue | address = updatedAddress }
                    in
                        { ev | venue = updatedVenue }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showStreetAddressError model.validationErrors (not <| streetAddressPresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueCity city ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentVenue =
                            ev.venue

                        currentAddress =
                            currentVenue.address

                        updatedAddress =
                            case currentAddress of
                                Just address ->
                                    Just { address | city = Just city }

                                Nothing ->
                                    Just { defaultAddress | city = Just city }

                        updatedVenue =
                            { currentVenue | address = updatedAddress }
                    in
                        { ev | venue = updatedVenue }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showCityError model.validationErrors (not <| cityPresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueState state ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentVenue =
                            ev.venue

                        currentAddress =
                            currentVenue.address

                        updatedAddress =
                            case currentAddress of
                                Just address ->
                                    Just { address | state = Just state }

                                Nothing ->
                                    Just { defaultAddress | state = Just state }

                        updatedVenue =
                            { currentVenue | address = updatedAddress }
                    in
                        { ev | venue = updatedVenue }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showStateError model.validationErrors (not <| statePresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueName name ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentVenue =
                            ev.venue

                        updatedVenue =
                            { currentVenue | name = Just name }
                    in
                        { ev | venue = updatedVenue }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showVenueNameError model.validationErrors (not <| venueNamePresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        ContactEmail email ->
            let
                updatedErrors =
                    showContactEmailError model.validationErrors (String.length email == 0)

                ev =
                    model.event

                updatedEvent =
                    let
                        currentContact =
                            ev.contact

                        updatedContact =
                            { currentContact | email = Just email }
                    in
                        { ev | contact = updatedContact }
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        ContactName name ->
            let
                updatedErrors =
                    showContactNameError model.validationErrors (String.length name == 0)

                ev =
                    model.event

                updatedEvent =
                    let
                        currentContact =
                            ev.contact

                        updatedContact =
                            { currentContact | name = Just name }
                    in
                        { ev | contact = updatedContact }
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        Day day ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentStartTS =
                            ev.startTimestamp

                        currentEndTS =
                            ev.endTimestamp

                        updatedStartTS =
                            { currentStartTS | ymd = day }

                        updatedEndTS =
                            { currentEndTS | ymd = day }
                    in
                        { ev
                            | startTimestamp = updatedStartTS
                            , endTimestamp = updatedEndTS
                        }
            in
                ( { model | event = updatedEvent }, Cmd.none )

        Hour borderTime hour ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentTS =
                            case borderTime of
                                StartTime ->
                                    ev.startTimestamp

                                EndTime ->
                                    ev.endTimestamp

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
                        case borderTime of
                            StartTime ->
                                { ev | startTimestamp = updatedTS }

                            EndTime ->
                                { ev | endTimestamp = updatedTS }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showDateError model.validationErrors (not <| datesOk updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        Minute borderTime minute ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentTS =
                            case borderTime of
                                StartTime ->
                                    ev.startTimestamp

                                EndTime ->
                                    ev.endTimestamp

                        updatedTS =
                            let
                                updatedMinute =
                                    case String.toInt minute of
                                        Ok min ->
                                            min

                                        Err err ->
                                            currentTS.minute
                            in
                                { currentTS | minute = updatedMinute }
                    in
                        case borderTime of
                            StartTime ->
                                { ev | startTimestamp = updatedTS }

                            EndTime ->
                                { ev | endTimestamp = updatedTS }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showDateError model.validationErrors (not <| datesOk updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        Meridiem borderTime meridiem ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentTS =
                            case borderTime of
                                StartTime ->
                                    ev.startTimestamp

                                EndTime ->
                                    ev.endTimestamp

                        updatedTS =
                            { currentTS | meridiem = meridiem }
                    in
                        case borderTime of
                            StartTime ->
                                { ev | startTimestamp = updatedTS }

                            EndTime ->
                                { ev | endTimestamp = updatedTS }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showDateError model.validationErrors (not <| datesOk updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        SubmitEvent ->
            if invalidInput model then
                ( { model | validationErrors = showValidationErrors model }
                , Cmd.none
                )
            else
                ( { model
                    | validationErrors = showValidationErrors model
                    , loading = True
                  }
                , Http.send CreateEventResult (createEvent model)
                )

        FetchEventsResult (Ok apiResult) ->
            let
                modelWithResult =
                    { model | loading = False, apiResult = apiResult }
            in
                case apiResult of
                    APIEvents events ->
                        ( { modelWithResult | events = events }, Cmd.none )

                    _ ->
                        ( modelWithResult, Cmd.none )

        FetchEventsResult (Err err) ->
            ( handleAPIError model err, Cmd.none )

        CreateEventResult (Ok apiResult) ->
            let
                modelWithResult =
                    { model | loading = False, apiResult = apiResult }
            in
                case apiResult of
                    APIEvent event ->
                        ( { modelWithResult | event = event, events = event :: model.events }, Cmd.none )

                    _ ->
                        ( modelWithResult, Cmd.none )

        CreateEventResult (Err err) ->
            ( handleAPIError model err, Cmd.none )


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


displayEventNameErrors : Model -> Bool
displayEventNameErrors model =
    model.validationErrors.showEventNameErrors && invalidInput model


eventsURL : Model -> String
eventsURL model =
    model.rootURL ++ "/api/events?slug=" ++ model.slug


handleAPIError : Model -> Http.Error -> Model
handleAPIError model err =
    let
        notLoadingModel =
            { model | loading = False }
    in
        case err of
            Http.BadStatus response ->
                let
                    decodeResult =
                        decodeString errorsDecoder response.body
                in
                    case decodeResult of
                        Ok apiResult ->
                            { notLoadingModel | apiResult = apiResult }

                        Err _ ->
                            { notLoadingModel | apiResult = APIErrors [ Error <| "Response failed: " ++ response.status.message ] }

            Http.BadPayload message response ->
                { notLoadingModel | apiResult = APIErrors [ Error "Unexpected response from server" ] }

            Http.BadUrl url ->
                { notLoadingModel | apiResult = APIErrors [ Error <| "Invalid URL: " ++ url ] }

            Http.Timeout ->
                { notLoadingModel | apiResult = APIErrors [ Error <| "Request timed out" ] }

            Http.NetworkError ->
                { notLoadingModel | apiResult = APIErrors [ Error <| "Network Error" ] }


createEvent : Model -> Http.Request APIResult
createEvent model =
    Http.post (eventsURL model)
        (jsonBody <| encodeEvent model)
        (oneOf [ dataEventDecoder, errorsDecoder ])


encodeEvent : Model -> Value
encodeEvent model =
    let
        { id, name, intro, contact, startTimestamp, endTimestamp, venue } =
            model.event
    in
        object
            [ ( "data"
              , object
                    [ ( "event"
                      , object
                            [ ( "name", JE.string name )
                            , ( "intro"
                              , if String.length intro > 0 then
                                    JE.string intro
                                else
                                    JE.null
                              )
                            , ( "contact", encodeContact contact )
                            , ( "start_time", JE.string <| serializeTimestamp startTimestamp )
                            , ( "end_time", JE.string <| serializeTimestamp endTimestamp )
                            , ( "author_id", JE.int <| model.authorID )
                            , ( "author_email", JE.string <| model.authorEmail )
                            , ( "venue", encodeVenue venue )
                            ]
                      )
                    ]
              )
            ]


encodeVenue : Venue -> Value
encodeVenue venue =
    let
        name =
            case venue.name of
                Just n ->
                    ( "name", JE.string n )

                Nothing ->
                    ( "name", JE.null )

        address =
            encodeAddress venue.address
    in
        object [ name, address ]


encodeAddress : Maybe Address -> ( String, Value )
encodeAddress address =
    let
        encodedAddress =
            case address of
                Just a ->
                    JE.object
                        [ ( "address1", encodeMaybeString a.address1 )
                        , ( "city", encodeMaybeString a.city )
                        , ( "state", encodeMaybeString a.state )
                        ]

                Nothing ->
                    JE.null
    in
        ( "address", encodedAddress )


encodeContact : Contact -> Value
encodeContact contact =
    let
        name =
            case contact.name of
                Just n ->
                    ( "name", JE.string n )

                Nothing ->
                    ( "name", JE.null )

        email =
            case contact.email of
                Just e ->
                    ( "email", JE.string e )

                Nothing ->
                    ( "email", JE.null )
    in
        object [ name, email ]


encodeMaybeString : Maybe String -> Value
encodeMaybeString mString =
    case mString of
        Just str ->
            JE.string str

        Nothing ->
            JE.null


getEvents : Model -> Http.Request APIResult
getEvents model =
    Http.get ((eventsURL model) ++ "&author_nb_id=" ++ (toString model.authorID))
        (oneOf [ errorsDecoder, dataEventsDecoder ])


dataEventsDecoder =
    JD.map APIEvents <|
        field "data" <|
            list <|
                eventDecoder


dataEventDecoder =
    JD.map APIEvent <|
        field "data" <|
            eventDecoder


errorsDecoder =
    JD.map APIErrors <|
        field "errors" <|
            list <|
                JD.map Error (field "title" string)


eventDecoder =
    field "event" <|
        JD.map7 Event
            eventID
            eventIntro
            contact
            eventName
            decodeStartTimestamp
            decodeEndTimestamp
            decodeVenue


decodeVenue =
    field "venue" <| JD.map2 Venue decodeVenueName decodeVenueAddress


decodeVenueName =
    JD.maybe <| field "name" string


decodeVenueAddress =
    JD.maybe <|
        field "address" <|
            JD.map3 Address
                (JD.maybe (field "address1" string))
                (JD.maybe (field "city" string))
                (JD.maybe (field "state" string))


decodeStartTimestamp =
    succeed defaultStartTimestamp


decodeEndTimestamp =
    succeed defaultEndTimestamp


eventID =
    field "id" int


eventName =
    field "name" (nullable string)
        |> JD.map (\m -> Maybe.withDefault "" m)


eventIntro =
    field "intro" (nullable string)
        |> JD.map (\m -> Maybe.withDefault "" m)


contact =
    field "contact" <|
        JD.map2 Contact contactName contactEmail


contactName =
    field "name" (nullable string)


contactEmail =
    field "email" (nullable string)
