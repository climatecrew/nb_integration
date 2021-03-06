module ContactMeForm exposing (Form, FormInputValues, errorResult, formInputValues, formInputsValid, setupForm, submit, successResult, updateEmail, updateFirstName, updateLastName, updateNotes, updatePhone)

import FormInput exposing (FormInput)
import FormResult exposing (FormResult)


type alias Form =
    { submitted : Bool
    , firstName : FormInput
    , lastName : FormInput
    , email : FormInput
    , phone : FormInput
    , mobile : FormInput
    , workPhoneNumber : FormInput
    , notes : FormInput
    , result : FormResult
    }


errorResult : Form -> ( String, List String ) -> Form
errorResult form ( message, distinctErrors ) =
    { form | result = FormResult.errorResult message distinctErrors }


successResult : Form -> String -> Form
successResult form message =
    { form | result = FormResult.successResult message }


type alias FormInputValues =
    { firstName : Maybe String
    , lastName : Maybe String
    , email : Maybe String
    , phone : Maybe String
    , mobile : Maybe String
    , workPhoneNumber : Maybe String
    , notes : Maybe String
    }


setupForm : FormInputValues -> Bool -> Form
setupForm values showNameInput =
    let
        isValid =
            \val -> String.length val > 0

        firstNameInput =
            case showNameInput of
                True ->
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
                        , errorMessage = \val -> "First Name is required"
                        }

                False ->
                    FormInput.setupNonInteractiveInput
                        { value = values.firstName }

        lastNameInput =
            case showNameInput of
                True ->
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
                        , errorMessage = \val -> "Last Name is required"
                        }

                False ->
                    FormInput.setupNonInteractiveInput
                        { value = values.lastName }

        emailInput =
            case values.email of
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
                        , errorMessage = \val -> "Email is required"
                        }

                Just email ->
                    FormInput.setupNonInteractiveInput
                        { value = Just email }

        phoneInput =
            case
                List.filterMap identity
                    [ values.phone
                    , values.mobile
                    , values.workPhoneNumber
                    ]
                    |> List.length
            of
                0 ->
                    FormInput.setupInteractiveInput
                        { inputType = FormInput.Input
                        , value = Nothing
                        , placeholder = "Optional"
                        , label = "Phone"
                        , for = "phone"
                        , id = "phone"
                        , type_ = "text"
                        , touched = False
                        , isValid = \_ -> True
                        , errorMessage = \_ -> ""
                        }

                otherwise ->
                    FormInput.setupNonInteractiveInput
                        { value = values.phone }

        mobileInput =
            FormInput.setupNonInteractiveInput
                { value = values.mobile }

        workPhoneNumberInput =
            FormInput.setupNonInteractiveInput
                { value = values.workPhoneNumber }

        notesInput =
            FormInput.setupInteractiveInput
                { inputType = FormInput.TextArea 7
                , value = Nothing
                , placeholder = "Comments or questions about your event idea"
                , label = "Notes"
                , for = "notes"
                , id = "notes"
                , type_ = "text"
                , touched = False
                , isValid = \_ -> True
                , errorMessage = \_ -> ""
                }
    in
    { submitted = False
    , firstName = firstNameInput
    , lastName = lastNameInput
    , email = emailInput
    , phone = phoneInput
    , mobile = mobileInput
    , workPhoneNumber = workPhoneNumberInput
    , notes = notesInput
    , result = FormResult.initialFormResult
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
    , mobile = FormInput.value form.mobile
    , workPhoneNumber = FormInput.value form.workPhoneNumber
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
