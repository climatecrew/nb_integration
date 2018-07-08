module ContactMeTypes exposing (..)

import Http


type Msg
    = FirstName String
    | LastName String
    | Email String
    | Phone String
    | Notes String
    | SubmitForm
    | SubmitFormResult (Result Http.Error APIResult)


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
    | APIContactRequest ContactRequest


type alias ContactRequest =
    String


type alias Error =
    { title : String }
