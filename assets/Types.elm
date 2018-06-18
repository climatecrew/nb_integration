module Types exposing (..)

import Http
import Dict exposing (Dict)
import EditingTimestamp exposing (EditingTimestamp, BorderTime, getTimestamp, defaultStartTimestamp, defaultEndTimestamp)


type Msg
    = SubmitEvent
    | FetchEventsResult (Result Http.Error APIResult)
    | CreateEventResult (Result Http.Error APIResult)
    | EventName String
    | EventIntro String
    | EventVenueName String
    | EventVenueAddress1 String
    | EventVenueCity String
    | EventVenueState String
    | ContactName String
    | ContactEmail String
    | Day String
    | Hour BorderTime String
    | Minute BorderTime String
    | Meridiem BorderTime String


type alias Model =
    { apiResult : APIResult
    , authorID : Int
    , authorEmail : String
    , event : Event
    , events : List Event
    , contact : Contact
    , rootURL : String
    , slug : String
    , loading : Bool
    , validationErrors : ValidationErrors
    , submitButtonPressed : Bool
    }


defaultModel : Model
defaultModel =
    let
        flags =
            defaultFlags
    in
        { apiResult = APIErrors []
        , authorID = flags.authorID
        , authorEmail = flags.authorEmail
        , event = defaultEvent
        , events = []
        , contact = defaultContact
        , rootURL = flags.rootURL
        , slug = flags.slug
        , loading = True
        , validationErrors = Dict.empty
        , submitButtonPressed = False
        }


markEventSubmitted : Model -> Model
markEventSubmitted model =
    { model | submitButtonPressed = True }


type alias ValidationErrors =
    Dict String Validation


type alias Validation =
    { valid : Bool
    , touched : Bool
    }


getError : Model -> String -> Bool
getError model errorKey =
    case Dict.get errorKey model.validationErrors of
        Nothing ->
            False

        Just validation ->
            (not validation.valid) && (validation.touched || model.submitButtonPressed)


setError : Model -> String -> Bool -> Model
setError model errorKey value =
    let
        updater =
            \validation ->
                Just <| Maybe.withDefault { valid = value, touched = False } validation

        updatedErrors =
            Dict.update errorKey updater model.validationErrors
    in
        { model | validationErrors = updatedErrors }


touchValidation : Model -> String -> Bool -> Model
touchValidation model errorKey value =
    let
        updater =
            \_ -> Just { valid = value, touched = True }

        updatedErrors =
            Dict.update errorKey updater model.validationErrors
    in
        { model | validationErrors = updatedErrors }


type alias Event =
    { id : Int
    , intro : String
    , name : String
    , startTimestamp : EditingTimestamp
    , endTimestamp : EditingTimestamp
    , venue : Venue
    }


defaultEvent : Event
defaultEvent =
    { id = 0
    , intro = ""
    , name = ""
    , startTimestamp = defaultStartTimestamp
    , endTimestamp = defaultEndTimestamp
    , venue = defaultVenue
    }


type alias Venue =
    { name : Maybe String
    , address : Maybe Address
    }


defaultVenue : Venue
defaultVenue =
    { name = Nothing
    , address = Nothing
    }


type alias Address =
    { address1 : Maybe String
    , city : Maybe String
    , state : Maybe String
    }


defaultAddress : Address
defaultAddress =
    { address1 = Nothing
    , city = Nothing
    , state = Nothing
    }


type alias Contact =
    { name : Maybe String
    , email : Maybe String
    }


defaultContact : Contact
defaultContact =
    { email = Nothing, name = Nothing }


type alias Error =
    { title : String }


type APIResult
    = APIErrors (List Error)
    | APIEvent Event
    | APIEvents (List Event)


currentTimestamp : Model -> BorderTime -> EditingTimestamp
currentTimestamp model borderTime =
    getTimestamp model.event borderTime


type alias Flags =
    { authorID : Int, authorEmail : String, rootURL : String, slug : String }


defaultFlags : Flags
defaultFlags =
    { authorID = 0
    , authorEmail = "author@example.com"
    , rootURL = "https://example.com"
    , slug = "example_slug"
    }
