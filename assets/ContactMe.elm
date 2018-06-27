module ContactMe exposing (Model, Msg, Flags, init, view, update)

import Html exposing (Html, div)


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
    div [] []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
