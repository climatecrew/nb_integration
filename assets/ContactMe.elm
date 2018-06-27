module ContactMe exposing (Model, Msg, Flags, init, view, update)

import Html exposing (Html, div, span, text, ul, li, input, label)
import Html.Attributes exposing (id, class, placeholder, style, type_, for)
import Html.Events exposing (onClick, onInput)


type Msg
    = FirstName String
    | LastName String
    | Email String
    | Phone String


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
                    [ label [ for "contact-name" ] [ text "First Name" ]
                    , input [ id "contact-name", type_ "contact-name", placeholder "Required", onInput FirstName ] []
                    , span
                        [ class <| validationClass <| getViewError model "contact.first_name"
                        , style [ ( "visibility", validationVisibility <| getViewError model "contact.name" ) ]
                        ]
                        [ text "First name must be present" ]
                    ]
                , li []
                    [ label [ for "contact-email" ] [ text "Email" ]
                    , input [ id "contact-email", type_ "contact-email", placeholder "Required", onInput Email ] []
                    , span
                        [ class <| validationClass <| getViewError model "contact.email"
                        , style [ ( "visibility", validationVisibility <| getViewError model "contact.email" ) ]
                        ]
                        [ text "Email must be present" ]
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
