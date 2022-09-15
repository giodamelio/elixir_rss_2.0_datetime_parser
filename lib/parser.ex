defmodule Rss20DatetimeParser.Parser do
  import NimbleParsec

  days = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
  ]

  day =
    choice(days |> Enum.map(&string/1))
    |> label("day of the week (#{Enum.join(days, " | ")})")

  months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ]

  month =
    choice(months |> Enum.map(&string/1))
    |> label("month of the year (#{Enum.join(months, " | ")})")

  two_digits = ascii_string([?0..?9], 2) |> label("two digits from 0 to 9")
  four_digits = ascii_string([?0..?9], 4) |> label("four digits from 0 to 9")

  date =
    two_digits
    |> ignore(string(" "))
    |> concat(month)
    |> ignore(string(" "))
    |> concat(two_digits)

  # Confusingly named, but I am sticking with the names as defined in RFC822
  hour =
    two_digits
    |> ignore(string(":"))
    |> concat(two_digits)
    |> optional(ignore(string(":")) |> concat(two_digits))

  offset =
    choice([string("+"), string("-")])
    |> concat(four_digits)

  zone =
    choice([
      string("UT"),
      string("GMT"),
      string("EST"),
      string("EDT"),
      string("CST"),
      string("CDT"),
      string("MST"),
      string("MDT"),
      string("PST"),
      string("PDT"),
      string("Z"),
      string("A"),
      string("M"),
      string("N"),
      string("Y"),
      offset
    ])
    |> label("a valid timezone")

  time =
    hour
    |> ignore(string(" "))
    |> concat(zone)

  datetime =
    optional(
      day
      |> ignore(string(", "))
    )
    |> concat(date)
    |> ignore(string(" "))
    |> concat(time)

  defparsec(:day, day)
  defparsec(:month, month)
  defparsec(:two_digits, two_digits)
  defparsec(:four_digits, four_digits)
  defparsec(:date, date)
  defparsec(:hour, hour)
  defparsec(:offset, offset)
  defparsec(:zone, zone)
  defparsec(:time, time)
  defparsec(:datetime, datetime)
end
