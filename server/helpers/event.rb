class Event
  def payload
    {
      "event"=> {
        "status"=>"unlisted",
        "name"=>"BBQ",
        "intro"=>"Let's Grill",
        "time_zone"=>"Eastern Time (US & Canada)",
        "start_time"=>"2018-06-01T12:00:00-00:00",
        "end_time"=>"2018-06-01T19:00:00-00:00",
        "contact"=>{
          "name"=>"Stephen",
          "contact_phone"=>"1234567890",
          "show_phone"=>true,
          "contact_email"=>"stephen@test.com",
          "email"=>"stephen@test.com",
          "show_email"=>true
        },
        "rsvp_form"=>{
          "phone"=>"optional",
          "address"=>"optional",
          "allow_guests"=>true,
          "accept_rsvps"=>true,
          "gather_volunteers"=>true
        },
        "show_guests"=>true,
        "capacity"=>80,
        "venue"=>{
          "name"=>"Stephen's Backyard",
          "address"=>{
            "address1"=>"123 Foo St",
            "city"=>"Cambridge",
            "state"=>"MA"
          }
        }
      }
    }
  end
end
