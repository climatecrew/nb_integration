module ContactMe exposing (Model, Msg, Flags, init, view, update)

import Html exposing (Html, div, span, text, ul, li, input, textarea, label, button)
import Html.Attributes exposing (id, class, placeholder, style, type_, for, rows, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as JD exposing (field, dict, list, string, array, int, oneOf, decodeString, succeed, nullable)
import Json.Encode as JE exposing (Value, encode, object)


type Msg
    = FirstName String
    | LastName String
    | Email String
    | Phone String
    | Notes String
    | SubmitForm
    | SubmitFormResult (Result Http.Error APIResult)


type alias Model =
    { personID : Maybe Int
    , firstName : String
    , lastName : String
    , email : String
    , phone : String
    , notes : String
    , rootURL : String
    , slug : String
    , loading : Bool
    }


type APIResult
    = APIErrors (List Error)
    | APIContactRequest ContactRequest


type alias ContactRequest =
    String


type alias Error =
    { title : String }


type alias Flags =
    { nbPersonID : Maybe Int
    , nbFirstName : Maybe String
    , nbLastName : Maybe String
    , nbEmail : Maybe String
    , nbPhone : Maybe String
    , rootURL : String
    , slug : String
    }


initialModel : Flags -> Model
initialModel flags =
    { personID = flags.nbPersonID
    , firstName = Maybe.withDefault "" flags.nbFirstName
    , lastName = Maybe.withDefault "" flags.nbLastName
    , email = Maybe.withDefault "" flags.nbEmail
    , phone = Maybe.withDefault "" flags.nbPhone
    , notes = ""
    , rootURL = flags.rootURL
    , slug = flags.slug
    , loading = False
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            initialModel flags
    in
        ( model, Cmd.none )


view : Model -> Html Msg
view model =
    mainView model


mainView : Model -> Html Msg
mainView model =
    div
        [ class "nb-integration-container" ]
        [ div [ class "form" ]
            [ ul [ class "flex-outer" ]
                [ li [ class "section-start" ]
                    [ label [ for "first-name" ] [ text "First Name" ]
                    , input [ id "first-name", type_ "last-name", placeholder "Required", value model.firstName, onInput FirstName ] []
                    , span
                        [ class <| validationClass <| getViewError model "contact.first_name"
                        , style [ ( "visibility", validationVisibility <| getViewError model "contact.first_name" ) ]
                        ]
                        [ text "First name must be present" ]
                    ]
                , li []
                    [ label [ for "last-name" ] [ text "Last Name" ]
                    , input [ id "last-name", type_ "last-name", placeholder "Required", value model.lastName, onInput LastName ] []
                    , span
                        [ class <| validationClass <| getViewError model "contact.last_name"
                        , style [ ( "visibility", validationVisibility <| getViewError model "contact.last_name" ) ]
                        ]
                        [ text "Last name must be present" ]
                    ]
                , li []
                    [ label [ for "email" ] [ text "Email" ]
                    , input [ id "email", type_ "email", placeholder "Required", value model.email, onInput Email ] []
                    , span
                        [ class <| validationClass <| getViewError model "contact.email"
                        , style [ ( "visibility", validationVisibility <| getViewError model "contact.email" ) ]
                        ]
                        [ text "Email must be present" ]
                    ]
                , li []
                    [ label [ for "phone" ] [ text "Phone" ]
                    , input [ id "phone", type_ "phone", value model.phone, onInput Phone ] []
                    , emptyValidationView
                    ]
                , li []
                    [ label [ for "notes" ] [ text "Notes" ]
                    , textarea [ id "notes", rows 5, onInput Notes ] []
                    , emptyValidationView
                    ]
                , li [ class <| submitButtonClass model ]
                    [ label [] []
                    , button [ onClick SubmitForm ] [ text "Submit" ]
                    , emptyValidationView
                    ]
                ]
            ]
        , loadingSpinner model
        ]


loadingSpinner : Model -> Html Msg
loadingSpinner model =
    if model.loading then
        div [ class "loader" ] []
    else
        div [] []


getViewError : Model -> String -> Bool
getViewError model errorKey =
    False


validationVisibility : Bool -> String
validationVisibility showErrors =
    if showErrors then
        "visible"
    else
        "hidden"


validationClass : Bool -> String
validationClass showErrors =
    if showErrors then
        "validation validation-errors"
    else
        "validation"


emptyValidationView : Html Msg
emptyValidationView =
    span [ class <| validationClass False ] []


submitButtonClass : Model -> String
submitButtonClass model =
    if invalidInput model then
        "create-event-button create-event-button-disabled"
    else
        "create-event-button"


invalidInput : Model -> Bool
invalidInput model =
    False


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FirstName firstName ->
            ( { model | firstName = firstName }, Cmd.none )

        LastName lastName ->
            ( { model | lastName = lastName }, Cmd.none )

        Email email ->
            ( { model | email = email }, Cmd.none )

        Phone phone ->
            ( { model | phone = phone }, Cmd.none )

        Notes notes ->
            ( { model | notes = notes }, Cmd.none )

        SubmitForm ->
            ( { model | loading = True }, Http.send SubmitFormResult (createContactRequest model) )

        SubmitFormResult result ->
            ( { model | loading = False }, Cmd.none )


contactRequestsURL : Model -> String
contactRequestsURL model =
    model.rootURL ++ "/api/contact_requests?slug=" ++ model.slug


createContactRequest : Model -> Http.Request APIResult
createContactRequest model =
    Http.post (contactRequestsURL model)
        (Http.jsonBody <| encodeContactRequest model)
        (oneOf [ dataContactRequestDecoder, errorsDecoder ])


encodeContactRequest : Model -> Value
encodeContactRequest model =
    let
        firstName =
            JE.string model.firstName

        lastName =
            JE.string model.lastName

        email =
            JE.string model.email

        phone =
            JE.string model.phone

        notes =
            JE.string model.notes

        person_id =
            case model.personID of
                Just id ->
                    JE.int id

                Nothing ->
                    JE.null
    in
        object
            [ ( "data"
              , object
                    [ ( "person"
                      , object
                            [ ( "id", person_id )
                            , ( "first_name", firstName )
                            , ( "last_name", lastName )
                            , ( "email", email )
                            , ( "phone", phone )
                            ]
                      )
                    , ( "notes", notes )
                    ]
              )
            ]


errorsDecoder =
    JD.map APIErrors <|
        field "errors" <|
            list <|
                JD.map Error (field "title" string)


dataContactRequestDecoder =
    JD.map APIContactRequest <|
        field "data" <|
            contactRequestDecoder


contactRequestDecoder =
    field "person" <| succeed "TEMP"
