# frozen_string_literal: true

class Person
  def payload
    {
      'person' => {
        'email' => 'gordon@cardiffelectric.com',
        'last_name' => 'Clark',
        'first_name' => 'Gordon',
        'sex' => 'M',
        'signup_type' => 0,
        'employer' => 'Cardiff Electric',
        'party' => 'L',
        'registered_address' => {
          'state' => 'TX',
          'country_code' => 'US'
        }
      }
    }
  end
end
