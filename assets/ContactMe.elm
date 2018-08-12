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
    { rootURL : String
    , slug : String
    , personID : Maybe Int
    , form : Form
    , loading : Bool
    }


type alias Msg =
    ContactMeTypes.Msg


type alias Flags =
    ContactMeTypes.Flags


initialModel : Flags -> Model
initialModel flags =
    { rootURL = flags.rootURL
    , slug = flags.slug
    , personID = flags.nbPersonID
    , form = ContactMeForm.setupForm flags
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
                [ li [ class "section-start" ] <|
                    FormInput.inputView model.form.submitted model.form.firstName FirstName
                , li [] <|
                    FormInput.inputView model.form.submitted model.form.lastName LastName
                , li [] <|
                    FormInput.inputView model.form.submitted model.form.email Email
                , li [] <|
                    FormInput.inputView model.form.submitted model.form.phone Phone
                , li [] <| FormInput.inputView model.form.submitted model.form.notes Notes
                , li [ class <| submitButtonClass model ]
                    [ label [] []
                    , button [ onClick SubmitForm ] [ text "Submit" ]
                    , emptyValidationView
                    ]
                , li [] <| ContactMeForm.resultsView model.form.results
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


emptyValidationView : Html Msg
emptyValidationView =
    span [ class "validation" ] []


submitButtonClass : Model -> String
submitButtonClass model =
    if ContactMeForm.formInputsValid model.form then
        "create-event-button"
    else
        "create-event-button create-event-button-disabled"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FirstName firstName ->
            ( { model | form = ContactMeForm.updateFirstName model.form firstName }, Cmd.none )

        LastName lastName ->
            ( { model | form = ContactMeForm.updateLastName model.form lastName }, Cmd.none )

        Email email ->
            ( { model | form = ContactMeForm.updateEmail model.form email }, Cmd.none )

        Phone phone ->
            ( { model | form = ContactMeForm.updatePhone model.form phone }, Cmd.none )

        Notes notes ->
            ( { model | form = ContactMeForm.updateNotes model.form notes }, Cmd.none )

        SubmitForm ->
            submitForm model

        SubmitFormResult result ->
            let
                parsedResults =
                    case result of
                        Ok a ->
                            Just a

                        Err err ->
                            case err of
                                Http.BadStatus response ->
                                    let
                                        _ =
                                            Debug.log "response" response
                                    in
                                        let
                                            decoded =
                                                JD.decodeString errorsDecoder response.body
                                        in
                                            case decoded of
                                                Ok ae ->
                                                    Just ae

                                                Err err ->
                                                    let
                                                        _ =
                                                            Debug.log "decode err" err
                                                    in
                                                        Nothing

                                otherwise ->
                                    Nothing

                _ =
                    Debug.log "parsedResults" parsedResults
            in
                ( { model | loading = False, form = ContactMeForm.updateResults model.form parsedResults }, Cmd.none )


submitForm : Model -> ( Model, Cmd Msg )
submitForm model =
    let
        { form } =
            model

        updatedModel =
            case ContactMeForm.formInputsValid model.form of
                True ->
                    { model | form = ContactMeForm.submit form, loading = True }

                False ->
                    { model | form = ContactMeForm.submit form, loading = False }

        cmd =
            if (not model.loading) && ContactMeForm.formInputsValid model.form then
                Http.send SubmitFormResult (createContactRequest model)
            else
                Cmd.none
    in
        ( updatedModel, cmd )


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
        values =
            ContactMeForm.formInputValues model.form

        firstName =
            encodeNullable JE.string values.firstName

        lastName =
            encodeNullable JE.string values.lastName

        email =
            encodeNullable JE.string values.email

        phone =
            encodeNullable JE.string values.phone

        mobile =
            encodeNullable JE.string values.mobile

        workPhoneNumber =
            encodeNullable JE.string values.workPhoneNumber

        notes =
            encodeNullable JE.string values.notes

        person_id =
            encodeNullable JE.int model.personID
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
                            , ( "mobile", mobile )
                            , ( "work_phone_number", workPhoneNumber )
                            ]
                      )
                    , ( "notes", notes )
                    ]
              )
            ]


encodeNullable : (t -> Value) -> Maybe t -> Value
encodeNullable encoder data =
    case data of
        Just d ->
            encoder d

        Nothing ->
            JE.null


errorsDecoder : JD.Decoder APIResult
errorsDecoder =
    JD.map APIErrors <|
        field "errors" <|
            list <|
                JD.map Error (field "title" string)


dataContactRequestDecoder : JD.Decoder APIResult
dataContactRequestDecoder =
    JD.map APIContactRequest <|
        field "data" <|
            contactRequestDecoder


contactRequestDecoder : JD.Decoder String
contactRequestDecoder =
    field "person" <| succeed "TEMP"
