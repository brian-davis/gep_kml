require_relative "../test_helper"

class TestDecimalToDegree < Minitest::Test
  def test_decimal_to_degree_no_cardinal_float
    arg = 6.385
    result = GepKml::Coordinates.decimal_to_degree(arg)
    expected = "6°23'6\""
    assert_equal(expected, result)
  end

  # bundle exec rake test TEST=test/test_decimal_to_degree.rb TESTOPTS="--name=test_decimal_to_degree_no_cardinal_float_negative -v"
  def test_decimal_to_degree_no_cardinal_float_negative
    arg = -6.385
    result = GepKml::Coordinates.decimal_to_degree(arg)
    expected = "-6°23'6\""
    assert_equal(expected, result)
  end

  def test_decimal_to_degree_no_cardinal_string
    arg = "6.385"
    result = GepKml::Coordinates.decimal_to_degree(arg)
    expected = "6°23'6\""
    assert_equal(expected, result)
  end

  def test_decimal_to_degree_no_cardinal_string_negative
    arg = "-6.385"
    result = GepKml::Coordinates.decimal_to_degree(arg)
    expected = "-6°23'6\""
    assert_equal(expected, result)
  end

  # 6.385
  # => "6°23'6\"N"
  def test_decimal_to_degree_north
    arg = 6.385
    result = GepKml::Coordinates.decimal_to_degree(arg, :latitude)
    expected = "6°23'6\"N"
    assert_equal(expected, result)
  end

  # -6.385
  # => "6°23'6\"S"
  def test_decimal_to_degree_south
    arg = -6.385
    result = GepKml::Coordinates.decimal_to_degree(arg, :latitude)
    expected = "6°23'6\"S"
    assert_equal(expected, result)
  end

  # 6.385
  # => "6°23'6\"E"
  def test_decimal_to_degree_east
    arg = 6.385
    result = GepKml::Coordinates.decimal_to_degree(arg, :longitude)
    expected = "6°23'6\"E"
    assert_equal(expected, result)
  end

  # -6.385
  # => "6°23'6\"W"
  def test_decimal_to_degree_west
    arg = -6.385
    result = GepKml::Coordinates.decimal_to_degree(arg, :longitude)
    expected = "6°23'6\"W"
    assert_equal(expected, result)
  end
end
