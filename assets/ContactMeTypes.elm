module ContactMeTypes exposing (APIResult(..), ContactRequest, Error, Flags, Msg(..))

import Dom
import Http



--import Spinner


type Msg
    = FirstName String
    | LastName String
    | Email String
    | Phone String
    | Notes String
    | SubmitForm
    | SubmitFormResult (Result Http.Error APIResult)
    | SubmitButtonUnfocused (Result Dom.Error ())



--    | SpinnerMsg Spinner.Msg


type alias Flags =
    { nbPersonID : Maybe Int
    , nbFirstName : Maybe String
    , nbLastName : Maybe String
    , nbEmail : Maybe String
    , nbPhone : Maybe String
    , nbMobile : Maybe String
    , nbWorkPhoneNumber : Maybe String
    , rootURL : String
    , slug : String
    }


type APIResult
    = APIErrors (List Error)
    | APIContactRequest


type alias ContactRequest =
    String


type alias Error =
    { title : Maybe String
    , detail : Maybe String
    }
