require_relative "../test_helper"

# bundle exec rake test TEST=test/test_degree_to_decimal.rb
class TestDecimalToDegree < Minitest::Test
  def test_degree_to_decimal_no_cardinal
    test_str = "6°23'6\""
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "6.385"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_no_cardinal_negative
    test_str = "-6°23'6\""
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-6.385"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_north
    test_str = "6°23'6\"N"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "6.385"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_south
    test_str = "6°23'6\"S"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-6.385"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_east
    test_str = "6°23'6\"E"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "6.385"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_west
    test_str = "6°23'6\"W"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-6.385"
    assert_equal(expected, result)
  end

  # bundle exec rake test TEST=test/test_degree_to_decimal.rb TESTOPTS="--name=test_degree_to_decimal_west_space -v"
  def test_degree_to_decimal_west_space
    test_str = "6°23'6\" W"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-6.385"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_south_decimal
    test_str = "66°33'11.8\"S"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-66.553278"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_south_decimal_space
    test_str = "66°33'11.8\" S"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-66.553278"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_east_decimal
    test_str = "99°50'20.8\"E"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "99.839111"
    assert_equal(expected, result)
  end

  def test_decimal_to_degree_south_decimal
    test_str = "-66.553278"
    result = GepKml::Coordinates.decimal_to_degree(test_str, :latitude)
    expected = "66°33'11.8\"S"
    assert_equal(expected, result)
  end

  def test_decimal_to_degree_east_decimal
    test_str = "99.839111"
    result = GepKml::Coordinates.decimal_to_degree(test_str, :longitude)
    expected = "99°50'20.8\"E"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_no_cardinal_degree_only
    test_str = "6°"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "6"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_degree_only_north
    test_str = "6°N"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "6"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_degree_only_south
    test_str = "6°S"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-6"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_degree_only_east
    test_str = "6°E"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "6"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_degree_only_west
    test_str = "6°W"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-6"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_degree_minute_only_north
    test_str = "6°23'N"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "6.383333"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_degree_minute_only_south
    test_str = "6°23'S"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-6.383333"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_degree_minute_only_east
    test_str = "6°23'E"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "6.383333"
    assert_equal(expected, result)
  end

  def test_degree_to_decimal_degree_minute_only_west
    test_str = "6°23'W"
    result = GepKml::Coordinates.degree_to_decimal(test_str)
    expected = "-6.383333"
    assert_equal(expected, result)
  end

  # bundle exec rake test TEST=test/test_degree_to_decimal.rb TESTOPTS="--name=test_degree_to_decimal_special_characters -v"
  def test_degree_to_decimal_special_characters
    # 37°01′28.51″N 4°32′46.65″W
    # https://en.wikipedia.org/wiki/Dolmen_of_Menga
    assert_equal(
      "37.024586",
      GepKml::Coordinates.degree_to_decimal("37°01′28.51″N"),
    )
    assert_equal(
      "-4.546292",
      GepKml::Coordinates.degree_to_decimal("4°32′46.65″W"),
    )
  end
end
