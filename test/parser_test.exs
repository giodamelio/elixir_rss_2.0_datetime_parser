defmodule Rss20DatetimeParser.ParserTest do
  use ExUnit.Case
  doctest Rss20DatetimeParser.Parser

  alias Rss20DatetimeParser.Parser

  describe "parse a day" do
    test "parse a day of the week" do
      assert Parser.day("Mon") == {:ok, [day: "Mon"], "", %{}, {1, 0}, 3}
      assert Parser.day("Tue") == {:ok, [day: "Tue"], "", %{}, {1, 0}, 3}
      assert Parser.day("Wed") == {:ok, [day: "Wed"], "", %{}, {1, 0}, 3}
      assert Parser.day("Thu") == {:ok, [day: "Thu"], "", %{}, {1, 0}, 3}
      assert Parser.day("Fri") == {:ok, [day: "Fri"], "", %{}, {1, 0}, 3}
      assert Parser.day("Sat") == {:ok, [day: "Sat"], "", %{}, {1, 0}, 3}
      assert Parser.day("Sun") == {:ok, [day: "Sun"], "", %{}, {1, 0}, 3}
    end

    test "errors upon unexpected day" do
      assert Parser.day("Nil") ==
               {:error, "expected day of the week (Mon | Tue | Wed | Thu | Fri | Sat | Sun)",
                "Nil", %{}, {1, 0}, 0}
    end
  end

  describe "parse a month" do
    test "parse a month of the year" do
      assert Parser.month("Jan") == {:ok, ["Jan"], "", %{}, {1, 0}, 3}
      assert Parser.month("Feb") == {:ok, ["Feb"], "", %{}, {1, 0}, 3}
      assert Parser.month("Mar") == {:ok, ["Mar"], "", %{}, {1, 0}, 3}
      assert Parser.month("Apr") == {:ok, ["Apr"], "", %{}, {1, 0}, 3}
      assert Parser.month("May") == {:ok, ["May"], "", %{}, {1, 0}, 3}
      assert Parser.month("Jun") == {:ok, ["Jun"], "", %{}, {1, 0}, 3}
      assert Parser.month("Jul") == {:ok, ["Jul"], "", %{}, {1, 0}, 3}
      assert Parser.month("Aug") == {:ok, ["Aug"], "", %{}, {1, 0}, 3}
      assert Parser.month("Sep") == {:ok, ["Sep"], "", %{}, {1, 0}, 3}
      assert Parser.month("Oct") == {:ok, ["Oct"], "", %{}, {1, 0}, 3}
      assert Parser.month("Nov") == {:ok, ["Nov"], "", %{}, {1, 0}, 3}
      assert Parser.month("Dec") == {:ok, ["Dec"], "", %{}, {1, 0}, 3}
    end

    test "errors upon unexpected month" do
      assert Parser.month("Nil") ==
               {:error,
                "expected month of the year (Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec)",
                "Nil", %{}, {1, 0}, 0}
    end
  end

  describe "two digits" do
    test "parse two digits" do
      assert Parser.two_digits("20") == {:ok, ["20"], "", %{}, {1, 0}, 2}
    end

    test "parse not digits" do
      assert Parser.two_digits("aa") ==
               {:error, "expected two digits from 0 to 9", "aa", %{}, {1, 0}, 0}
    end
  end

  describe "four digits" do
    test "parse four digits" do
      assert Parser.four_digits("2020") == {:ok, ["2020"], "", %{}, {1, 0}, 4}
    end

    test "parse not digits" do
      assert Parser.four_digits("aaaa") ==
               {:error, "expected four digits from 0 to 9", "aaaa", %{}, {1, 0}, 0}
    end
  end

  describe "parse a date" do
    test "parse a valid date" do
      assert Parser.date("20 Sep 96") == {:ok, [date: ["20", "Sep", "96"]], "", %{}, {1, 0}, 9}
    end
  end

  describe "parse an hour" do
    test "parse a valid hour" do
      assert Parser.hour("01:01") == {:ok, ["01", "01"], "", %{}, {1, 0}, 5}
    end

    test "parse a valid hour with seconds" do
      assert Parser.hour("01:01:01") == {:ok, ["01", "01", "01"], "", %{}, {1, 0}, 8}
    end
  end

  describe "parse a time offset" do
    test "parses a valid offset" do
      assert Parser.offset("+2222") == {:ok, ["+", "2222"], "", %{}, {1, 0}, 5}
      assert Parser.offset("-2222") == {:ok, ["-", "2222"], "", %{}, {1, 0}, 5}
    end

    test "error on invalid offset" do
      assert Parser.offset("=2222") ==
               {:error, "expected string \"+\" or string \"-\"", "=2222", %{}, {1, 0}, 0}

      assert Parser.offset("+22") ==
               {:error, "expected four digits from 0 to 9", "22", %{}, {1, 0}, 1}
    end
  end

  describe "parse a zone" do
    test "parse a hardcoded zone" do
      assert Parser.zone("UT") == {:ok, ["UT"], "", %{}, {1, 0}, 2}
      assert Parser.zone("PDT") == {:ok, ["PDT"], "", %{}, {1, 0}, 3}
    end

    test "parse a military offset" do
      assert Parser.zone("Z") == {:ok, ["Z"], "", %{}, {1, 0}, 1}
      assert Parser.zone("M") == {:ok, ["M"], "", %{}, {1, 0}, 1}
    end

    test "parse an offset" do
      assert Parser.zone("+1000") == {:ok, ["+", "1000"], "", %{}, {1, 0}, 5}
    end

    test "error on invalid offset" do
      assert Parser.zone("CEST") == {:error, "expected a valid timezone", "CEST", %{}, {1, 0}, 0}
      assert Parser.zone("+22") == {:error, "expected a valid timezone", "22", %{}, {1, 0}, 1}
    end
  end

  describe "parse a time" do
    test "parse a valid time" do
      assert Parser.time("01:01:01 UT") ==
               {:ok, [time: ["01", "01", "01", "UT"]], "", %{}, {1, 0}, 11}

      assert Parser.time("02:02:02 EST") ==
               {:ok, [time: ["02", "02", "02", "EST"]], "", %{}, {1, 0}, 12}
    end
  end

  describe "parse datetimes" do
    test "parse a valid datetime" do
      assert Parser.datetime("Mon, 12 Sep 82 17:53 EDT") ==
               {:ok, [day: "Mon", date: ["12", "Sep", "82"], time: ["17", "53", "EDT"]], "", %{},
                {1, 0}, 24}

      assert Parser.datetime("12 Sep 82 17:53 EDT") ==
               {:ok, [date: ["12", "Sep", "82"], time: ["17", "53", "EDT"]], "", %{}, {1, 0}, 19}

      assert Parser.datetime("12 Sep 82 17:53:00 EDT") ==
               {:ok, [date: ["12", "Sep", "82"], time: ["17", "53", "00", "EDT"]], "", %{},
                {1, 0}, 22}
    end
  end
end
