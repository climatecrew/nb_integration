module Types exposing (..)

import Http


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


type alias Event =
    { id : Int
    , intro : String
    , contact : Contact
    , name : String
    , startTimestamp : EditingTimestamp
    , endTimestamp : EditingTimestamp
    , venue : Venue
    }


defaultEvent : Event
defaultEvent =
    { id = 0
    , intro = ""
    , contact = { email = Nothing, name = Nothing }
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


type alias EditingTimestamp =
    { border : BorderTime, ymd : String, hour : Int, minute : Int, meridiem : String }


defaultStartTimestamp : EditingTimestamp
defaultStartTimestamp =
    { border = StartTime, ymd = "2018-09-03", hour = 1, minute = 0, meridiem = "PM" }


defaultEndTimestamp : EditingTimestamp
defaultEndTimestamp =
    { border = EndTime, ymd = "2018-09-03", hour = 4, minute = 0, meridiem = "PM" }


type alias Error =
    { title : String }


type BorderTime
    = StartTime
    | EndTime


type APIResult
    = APIErrors (List Error)
    | APIEvent Event
    | APIEvents (List Event)


type alias ShowValidationErrors =
    { showEventNameErrors : Bool
    , showContactNameErrors : Bool
    , showContactEmailErrors : Bool
    , showDateErrors : Bool
    , showVenueNameErrors : Bool
    , showStreetAddressErrors : Bool
    , showCityErrors : Bool
    , showStateErrors : Bool
    }


defaultShowValidationErrors : ShowValidationErrors
defaultShowValidationErrors =
    { showEventNameErrors = False
    , showContactNameErrors = False
    , showContactEmailErrors = False
    , showDateErrors = False
    , showVenueNameErrors = False
    , showStreetAddressErrors = False
    , showCityErrors = False
    , showStateErrors = False
    }


type alias Model =
    { apiResult : APIResult
    , authorID : Int
    , authorEmail : String
    , event : Event
    , events : List Event
    , rootURL : String
    , slug : String
    , loading : Bool
    , validationErrors : ShowValidationErrors
    }


defaultModel : Flags -> Model
defaultModel flags =
    { apiResult = APIErrors []
    , authorID = flags.authorID
    , authorEmail = flags.authorEmail
    , event = defaultEvent
    , events = []
    , rootURL = flags.rootURL
    , slug = flags.slug
    , loading = True
    , validationErrors = defaultShowValidationErrors
    }


currentTimestamp : Model -> BorderTime -> EditingTimestamp
currentTimestamp model borderTime =
    case borderTime of
        StartTime ->
            model.event.startTimestamp

        EndTime ->
            model.event.endTimestamp


type alias Flags =
    { authorID : Int, authorEmail : String, rootURL : String, slug : String }
