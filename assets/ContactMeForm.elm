module ContactMeForm exposing (..)

import ContactMeTypes exposing (Flags)
import FormInput exposing (FormInput)


type alias Form =
    { submitted : Bool
    , firstName : FormInput
    , lastName : FormInput
    , email : FormInput
    , phone : FormInput
    , notes : FormInput
    }


type alias FormInputValues =
    { firstName : Maybe String
    , lastName : Maybe String
    , email : Maybe String
    , phone : Maybe String
    , notes : Maybe String
    }


setupForm : Flags -> Form
setupForm flags =
    let
        isValid =
            (\val -> String.length val > 0)

        firstNameInput =
            case flags.nbPersonID of
                Nothing ->
                    FormInput.setupInteractiveInput
                        { inputType = FormInput.Input
                        , value = Nothing
                        , placeholder = "Required"
                        , label = "First Name"
                        , for = "first_name"
                        , id = "first_name"
                        , type_ = "first_name"
                        , touched = False
                        , isValid = isValid
                        , errorMessage = (\val -> "First Name is required")
                        }

                Just _ ->
                    FormInput.setupNonInteractiveInput
                        { value = flags.nbFirstName }

        lastNameInput =
            case flags.nbPersonID of
                Nothing ->
                    FormInput.setupInteractiveInput
                        { inputType = FormInput.Input
                        , value = Nothing
                        , placeholder = "Required"
                        , label = "Last Name"
                        , for = "last_name"
                        , id = "last_name"
                        , type_ = "last_name"
                        , touched = False
                        , isValid = isValid
                        , errorMessage = (\val -> "Last Name is required")
                        }

                Just _ ->
                    FormInput.setupNonInteractiveInput
                        { value = flags.nbLastName }

        emailInput =
            case flags.nbEmail of
                Nothing ->
                    FormInput.setupInteractiveInput
                        { inputType = FormInput.Input
                        , value = Nothing
                        , placeholder = "Required"
                        , label = "Email"
                        , for = "email"
                        , id = "email"
                        , type_ = "email"
                        , touched = False
                        , isValid = isValid
                        , errorMessage = (\val -> "Email is required")
                        }

                Just email ->
                    FormInput.setupNonInteractiveInput
                        { value = Just email }

        phoneInput =
            case flags.nbPhone of
                Nothing ->
                    FormInput.setupInteractiveInput
                        { inputType = FormInput.Input
                        , value = Nothing
                        , placeholder = "Optional"
                        , label = "Phone"
                        , for = "phone"
                        , id = "phone"
                        , type_ = "text"
                        , touched = False
                        , isValid = (\_ -> True)
                        , errorMessage = (\_ -> "")
                        }

                Just phone ->
                    FormInput.setupNonInteractiveInput
                        { value = Just phone }

        notesInput =
            FormInput.setupInteractiveInput
                { inputType = FormInput.TextArea 5
                , value = Nothing
                , placeholder = "Comments or questions about your event idea"
                , label = "Notes"
                , for = "notes"
                , id = "notes"
                , type_ = "text"
                , touched = False
                , isValid = (\_ -> True)
                , errorMessage = (\_ -> "")
                }
    in
        { submitted = False
        , firstName = firstNameInput
        , lastName = lastNameInput
        , email = emailInput
        , phone = phoneInput
        , notes = notesInput
        }


updateFirstName : Form -> String -> Form
updateFirstName form value =
    { form | firstName = FormInput.updateFormInput form.firstName value }


updateLastName : Form -> String -> Form
updateLastName form value =
    { form | lastName = FormInput.updateFormInput form.lastName value }


updateEmail : Form -> String -> Form
updateEmail form value =
    { form | email = FormInput.updateFormInput form.email value }


updatePhone : Form -> String -> Form
updatePhone form value =
    { form | phone = FormInput.updateFormInput form.phone value }


updateNotes : Form -> String -> Form
updateNotes form value =
    { form | notes = FormInput.updateFormInput form.notes value }


formInputValues : Form -> FormInputValues
formInputValues form =
    { firstName = FormInput.value form.firstName
    , lastName = FormInput.value form.lastName
    , email = FormInput.value form.email
    , phone = FormInput.value form.phone
    , notes = FormInput.value form.notes
    }


formInputsValid : Form -> Bool
formInputsValid form =
    List.all identity <|
        List.map FormInput.valid
            [ form.firstName
            , form.lastName
            , form.email
            , form.phone
            , form.notes
            ]


submit : Form -> Form
submit form =
    { form | submitted = True }
