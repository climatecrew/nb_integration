module ContactMe exposing (Model, Msg, Flags, init, view, update)

import Html exposing (Html, div, span, text, ul, li, input, textarea, label, button)
import Html.Attributes exposing (id, class, placeholder, style, type_, for, rows)
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
    { first_name : String
    , last_name : String
    , email : String
    , phone : String
    , notes : String
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


type alias Flags =
    { nbID : Maybe Int, nbEmail : Maybe String, rootURL : String, slug : String }


initialModel : Flags -> Model
initialModel flags =
    { first_name = ""
    , last_name = ""
    , email = ""
    , phone = ""
    , notes = ""
    , rootURL = flags.rootURL
    , slug = flags.slug
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
                    , input [ id "first-name", type_ "last-name", placeholder "Required", onInput FirstName ] []
                    , span
                        [ class <| validationClass <| getViewError model "contact.first_name"
                        , style [ ( "visibility", validationVisibility <| getViewError model "contact.first_name" ) ]
                        ]
                        [ text "First name must be present" ]
                    ]
                , li []
                    [ label [ for "last-name" ] [ text "Last Name" ]
                    , input [ id "last-name", type_ "last-name", placeholder "Required", onInput LastName ] []
                    , span
                        [ class <| validationClass <| getViewError model "contact.last_name"
                        , style [ ( "visibility", validationVisibility <| getViewError model "contact.last_name" ) ]
                        ]
                        [ text "Last name must be present" ]
                    ]
                , li []
                    [ label [ for "email" ] [ text "Email" ]
                    , input [ id "email", type_ "email", placeholder "Required", onInput Email ] []
                    , span
                        [ class <| validationClass <| getViewError model "contact.email"
                        , style [ ( "visibility", validationVisibility <| getViewError model "contact.email" ) ]
                        ]
                        [ text "Email must be present" ]
                    ]
                , li []
                    [ label [ for "phone" ] [ text "Phone" ]
                    , input [ id "phone", type_ "phone", onInput Phone ] []
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
        ]


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
        FirstName first_name ->
            ( { model | first_name = first_name }, Cmd.none )

        LastName last_name ->
            ( { model | last_name = last_name }, Cmd.none )

        Email email ->
            ( { model | email = email }, Cmd.none )

        Phone phone ->
            ( { model | phone = phone }, Cmd.none )

        Notes notes ->
            ( { model | notes = notes }, Cmd.none )

        SubmitForm ->
            ( model, Http.send SubmitFormResult (createContactRequest model) )

        SubmitFormResult result ->
            ( model, Cmd.none )


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
        first_name =
            JE.string model.first_name

        last_name =
            JE.string model.last_name

        email =
            JE.string model.email

        phone =
            JE.string model.phone

        notes =
            JE.string model.notes
    in
        object
            [ ( "data"
              , object
                    [ ( "person"
                      , object
                            [ ( "first_name", first_name )
                            , ( "last_name", last_name )
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
