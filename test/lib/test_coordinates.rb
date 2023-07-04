require_relative "../test_helper"

# bundle exec rake test TEST=test/test_coordinates.rb
class TestCoordinates < Minitest::Test
  ### Instance methods ###
  def test_antipode!
    subject =
      GepKml::Coordinates.new(
        { kml_csv: "-75.12640974398208,-14.69586512288908,0" },
      )
    subject.antipode!
    assert_equal("104.87359,14.695865,0.0", subject.to_s)
  end

  def test_gep_coordinates_new
    # https://www.megalithic.co.uk/article.php?sid=60
    # Latitude: 54.093736N  Longitude: 1.404127W
    subject =
      GepKml::Coordinates.new(
        { latitude: "54.093736N", longitude: "1.404127W" },
      )

    assert_equal(54.093736, subject.latitude)
    assert_equal(-1.404127, subject.longitude)
  end

  def test_gep_coordinates_str
    # as in GEP KML
    # "-1.404127,54.093736,0"
    subject = GepKml::Coordinates.new({ kml_csv: "-1.404127,54.093736,0" })

    assert_equal(54.093736, subject.latitude)
    assert_equal(-1.404127, subject.longitude)
  end

  # bundle exec rake test TEST=test/test_coordinates.rb TESTOPTS="--name=test_gep_coordinates_str_guard -v"
  def test_gep_coordinates_str_guard
    subject = GepKml::Coordinates.new({ kml_csv: "" })
    assert_nil(subject.latitude)

    subject = GepKml::Coordinates.new({ kml_csv: "123.456" })
    assert_nil(subject.latitude)

    subject = GepKml::Coordinates.new({ kml_csv: "nonsense" })
    assert_nil(subject.latitude)
  end

  def test_to_s
    # https://www.megalithic.co.uk/article.php?sid=60
    # Latitude: 54.093736N  Longitude: 1.404127W
    subject =
      GepKml::Coordinates.new(
        { latitude: "54.093736N", longitude: "1.404127W" },
      )

    assert_equal(subject.to_s, "-1.404127,54.093736,0.0")
  end

  # bundle exec rake test TEST=test/test_coordinates.rb TESTOPTS="--name=test_to_human -v"
  def test_to_human
    subject =
      GepKml::Coordinates.new(
        { latitude: "54.093736N", longitude: "1.404127W" },
      )

    result = subject.to_human
    expected = "54.093736,-1.404127,0.0"
    assert_equal(expected, result)
  end

  # bundle exec rake test TEST=test/test_coordinates.rb TESTOPTS="--name=test_wikipedia_string -v"
  def test_wikipedia_string
    # 37°01′28.51″N 4°32′46.65″W
    # https://en.wikipedia.org/wiki/Dolmen_of_Menga

    coordinates =
      GepKml::Coordinates.new(
        { latitude: "37°01′28.51″N", longitude: "4°32′46.65″W" },
      )

    refute_nil(coordinates)
    assert_equal(37.024586, coordinates.latitude)
    assert_equal(-4.546292, coordinates.longitude)
  end

  # bundle exec rake test TEST=test/test_coordinates.rb TESTOPTS="--name=test_force_decimal -v"
  def test_force_decimal
    assert_equal(
      "37.024586",
      GepKml::Coordinates.force_decimal("37°01′28.51″N"),
    )
    assert_equal("37.024586", GepKml::Coordinates.force_decimal("37.024586"))
    assert_equal("37.024586", GepKml::Coordinates.force_decimal(37.024586))
    assert_equal("-37.024586", GepKml::Coordinates.force_decimal(-37.024586))
    assert_equal(
      "-37.024586",
      GepKml::Coordinates.force_decimal("-37.024586"),
    )
    assert_equal(
      "37.024586",
      GepKml::Coordinates.force_decimal("37.024586 N"),
    )
    assert_equal("37.024586", GepKml::Coordinates.force_decimal("37.024586N"))
    assert_nil(GepKml::Coordinates.force_decimal("Nonsense"))
  end

  # bundle exec rake test TEST=test/test_coordinates.rb TESTOPTS="--name=test_combined_string1 -v"
  def test_combined_string1
    # 37°01′28.51″N 4°32′46.65″W
    # https://en.wikipedia.org/wiki/Dolmen_of_Menga

    coordinates =
      GepKml::Coordinates.new({ simple: "37°01′28.51″N 4°32′46.65″W" })
    refute_nil(coordinates)
    assert_equal(37.024586, coordinates.latitude)
    assert_equal(-4.546292, coordinates.longitude)
  end

  # bundle exec rake test TEST=test/test_coordinates.rb TESTOPTS="--name=test_combined_string2 -v"
  def test_combined_string2
    # 37°01′28.51″N 4°32′46.65″W
    # https://en.wikipedia.org/wiki/Dolmen_of_Menga

    coordinates =
      GepKml::Coordinates.new({ simple: "37°01′28.51″ N 4°32′46.65″ W" })
    refute_nil(coordinates)
    assert_equal(37.024586, coordinates.latitude)
    assert_equal(-4.546292, coordinates.longitude)
  end
end
