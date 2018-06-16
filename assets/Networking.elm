module Networking exposing (..)

import Http exposing (jsonBody)
import Json.Decode as JD exposing (field, dict, list, string, array, int, oneOf, decodeString, succeed, nullable)
import Json.Encode as JE exposing (Value, encode, object)
import Types exposing (..)
import EditingTimestamp exposing (defaultStartTimestamp, defaultEndTimestamp)
import Utilities exposing (..)


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
        { id, name, intro, startTimestamp, endTimestamp, venue } =
            model.event

        { contact } =
            model
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
        JD.map6 Event
            eventID
            eventIntro
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
