module ContactMe exposing (Model, Msg, Flags, init, view, update)

import Html exposing (Html, div, span, text, ul, li, input, textarea, label, button)
import Html.Attributes exposing (id, class, placeholder, style, type_, for, rows, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as JD exposing (field, dict, list, string, array, int, oneOf, decodeString, succeed, nullable)
import Json.Encode as JE exposing (Value, encode, object)
import ContactMeForm exposing (Form)
import FormInput exposing (FormInput)
import ContactMeTypes exposing (..)


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
    , form : Form
    }


type alias Msg =
    ContactMeTypes.Msg


type alias Flags =
    ContactMeTypes.Flags


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
    , form = ContactMeForm.setupForm flags
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
                [ li [ class "section-start" ] <|
                    FormInput.inputView model.form.submitted model.form.firstName FirstName
                , li [] <|
                    FormInput.inputView model.form.submitted model.form.lastName LastName
                , li [] <|
                    FormInput.inputView model.form.submitted model.form.email Email
                , li [] <|
                    FormInput.inputView model.form.submitted model.form.phone Phone
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
            ( { model | firstName = firstName, form = ContactMeForm.updateFirstName model.form firstName }, Cmd.none )

        LastName lastName ->
            ( { model | lastName = lastName, form = ContactMeForm.updateLastName model.form lastName }, Cmd.none )

        Email email ->
            ( { model | email = email, form = ContactMeForm.updateEmail model.form email }, Cmd.none )

        Phone phone ->
            ( { model | phone = phone, form = ContactMeForm.updatePhone model.form phone }, Cmd.none )

        Notes notes ->
            ( { model | notes = notes }, Cmd.none )

        SubmitForm ->
            ( submitForm model, Http.send SubmitFormResult (createContactRequest model) )

        SubmitFormResult result ->
            ( { model | loading = False }, Cmd.none )


submitForm : Model -> Model
submitForm model =
    let
        { form } =
            model

        updatedForm =
            ContactMeForm.submit form
    in
        { model | loading = True, form = updatedForm }


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
