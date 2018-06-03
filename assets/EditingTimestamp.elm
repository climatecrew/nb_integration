module EditingTimestamp exposing (..)


type alias Scheduled a =
    { a | startTimestamp : EditingTimestamp, endTimestamp : EditingTimestamp }


type BorderTime
    = StartTime
    | EndTime


startTime : BorderTime
startTime =
    StartTime


endTime : BorderTime
endTime =
    EndTime


type alias EditingTimestamp =
    { border : BorderTime, ymd : String, hour : Int, minute : Int, meridiem : String }


getTimestamp : Scheduled a -> BorderTime -> EditingTimestamp
getTimestamp { startTimestamp, endTimestamp } borderTime =
    case borderTime of
        StartTime ->
            startTimestamp

        EndTime ->
            endTimestamp


defaultStartTimestamp : EditingTimestamp
defaultStartTimestamp =
    { border = StartTime, ymd = "2018-09-03", hour = 1, minute = 0, meridiem = "PM" }


defaultEndTimestamp : EditingTimestamp
defaultEndTimestamp =
    { border = EndTime, ymd = "2018-09-03", hour = 4, minute = 0, meridiem = "PM" }
