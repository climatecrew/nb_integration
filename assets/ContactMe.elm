module ContactMe exposing (Model, Msg, Flags, init, view, update)

import ContactMeForm exposing (Form)
import ContactMeTypes exposing (..)
import Dom
import FormInput exposing (FormInput)
import FormResult exposing (FormResult)
import Html exposing (Html, div, span, text, ul, li, input, textarea, label, button)
import Html.Attributes exposing (id, class, placeholder, style, type_, for, rows, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Task


type alias Model =
    { rootURL : String
    , slug : String
    , personID : Maybe Int
    , form : Form
    , loading : Bool
    , complete : Bool
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
    , complete = False
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
            [ ul [ class "flex-outer" ] <|
                List.append
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
                        , button [ onClick SubmitForm, id "submit-button" ] [ text "Submit" ]
                        , emptyValidationView
                        ]
                    ]
                <|
                    FormResult.resultView model.form.result
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
    if ContactMeForm.formInputsValid model.form && not model.loading && not model.complete then
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
            submitFormResult model result

        SubmitButtonUnfocused result ->
            ( model, Cmd.none )


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
        dataContactRequestDecoder


encodeContactRequest : Model -> JE.Value
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
        JE.object
            [ ( "data"
              , JE.object
                    [ ( "person"
                      , JE.object
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


encodeNullable : (t -> JE.Value) -> Maybe t -> JE.Value
encodeNullable encoder data =
    case data of
        Just d ->
            encoder d

        Nothing ->
            JE.null


errorsDecoder : JD.Decoder (List Error)
errorsDecoder =
    JD.field "errors" <|
        JD.list <|
            JD.map2 Error
                (JD.maybe (JD.field "title" JD.string))
                (JD.maybe (JD.field "detail" JD.string))


dataContactRequestDecoder : JD.Decoder APIResult
dataContactRequestDecoder =
    JD.succeed APIContactRequest


submitFormResult : Model -> Result Http.Error APIResult -> ( Model, Cmd Msg )
submitFormResult model result =
    let
        complete =
            case result of
                Ok _ ->
                    True

                otherwise ->
                    False

        msg =
            Dom.blur "submit-button"
                |> Task.attempt SubmitButtonUnfocused
    in
        ( { model
            | loading = False
            , complete = complete
            , form = updateFormResult model.form result
          }
        , msg
        )


updateFormResult : Form -> Result Http.Error APIResult -> Form
updateFormResult form result =
    case result of
        Ok _ ->
            ContactMeForm.successResult form "Thanks for reaching out! We will follow up to help plan your event."

        Err err ->
            transformHttpError form err


transformHttpError : Form -> Http.Error -> Form
transformHttpError form httpError =
    case httpError of
        Http.BadUrl _ ->
            ContactMeForm.errorResult form ( "Submission failed:", [ "Sorry, an unexpected error happened on our side. Please try again later." ] )

        Http.Timeout ->
            ContactMeForm.errorResult form ( "Submission failed:", [ "Request timed out. Please try again." ] )

        Http.NetworkError ->
            ContactMeForm.errorResult form ( "Submission failed:", [ "Network error. Please ensure your Internet connection is working and try again." ] )

        Http.BadStatus response ->
            let
                httpStatus =
                    toString response.status.code ++ " " ++ response.status.message

                decodeResult =
                    Result.withDefault [ { title = Just httpStatus, detail = Nothing } ] <|
                        JD.decodeString errorsDecoder response.body

                errorChooser =
                    \e ->
                        case e.detail of
                            Just detail ->
                                Just detail

                            Nothing ->
                                e.title

                errorList =
                    List.filterMap errorChooser decodeResult
            in
                ContactMeForm.errorResult form ( "Submission failed:", errorList )

        -- BadPayload: success response code but undecodable response body
        -- Likely means API changed
        Http.BadPayload _ _ ->
            ContactMeForm.successResult form "Thanks for reaching out! We will follow up to help plan your event."
