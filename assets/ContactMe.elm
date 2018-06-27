module ContactMe exposing (Model, Msg, Flags, init, view, update)

import Html exposing (Html, div, span, text, ul, li, input, label, button)
import Html.Attributes exposing (id, class, placeholder, style, type_, for)
import Html.Events exposing (onClick, onInput)


type Msg
    = FirstName String
    | LastName String
    | Email String
    | Phone String
    | SubmitForm


type alias Model =
    { first_name : String
    , last_name : String
    , email : String
    , phone : String
    }


type alias Flags =
    { nbID : Maybe Int, nbEmail : Maybe String, rootURL : String, slug : String }


initialModel : Flags -> Model
initialModel flags =
    { first_name = ""
    , last_name = ""
    , email = ""
    , phone = ""
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
    ( model, Cmd.none )
