require_relative "../test_helper"

# bundle exec rake test TEST=test/test_great_circle.rb
class TestCoordinates < Minitest::Test
  def test_initialize
    assert_kind_of(GepKml::Pin, tester.pin1)
    assert_kind_of(GepKml::Pin, tester.pin2)
    assert_nil(tester.filename)
    assert_nil(tester.filepath)
  end

  def test_text
    subject = tester.dup
    assert_match(/Document/, subject.text)
  end

  def test_xml
    subject = tester.dup
    assert_kind_of(Nokogiri::XML::Document, subject.xml)
  end

  def test_name
    subject = tester.dup
    refute_nil(subject.name)
  end

  def test_name=
    subject = tester.dup
    subject.name = "New Name"
    assert_equal("New Name", subject.name)
  end

  def test_coordinates
    subject = tester.dup
    expected =
      "-1.826198,51.178812,0.0 <!-- Stonehenge -->\n36.204209,34.007011,0.0 <!-- Temple of Jupiter, Baalbek -->\n178.173802,-51.178812,0.0 <!-- Stonehenge antipode -->\n-143.795791,-34.007011,0.0 <!-- Temple of Jupiter, Baalbek antipode -->\n-1.826198,51.178812,0.0 <!-- Stonehenge -->"
    assert_equal(expected, subject.coordinates)
    assert_equal(
      expected,
      subject.xml.css("Document Placemark LineString coordinates")&.first&.text,
    )
    assert_match(/antipode/, subject.text)
    assert_equal(
      "Stonehenge-Temple of Jupiter, Baalbek Great Circle",
      subject.name,
    )
  end

  def test_great_circle_coordinates_simple
    point1 = "-75.12640974398208,-14.69586512288908,0"
    point2 = "-75.11900813118717,-14.6931973885307,0"
    result = GepKml::GreatCircle.great_circle_coordinates(point1, point2)
    expected =
      "-75.12641,-14.695865,0.0 <!-- coordinate1 -->\n-75.119008,-14.693197,0.0 <!-- coordinate2 -->\n104.87359,14.695865,0.0 <!-- coordinate1 antipode -->\n104.880992,14.693197,0.0 <!-- coordinate2 antipode -->\n-75.12641,-14.695865,0.0 <!-- coordinate1 -->"
    assert_equal(expected, result)
  end

  def test_great_circle_coordinates_comments
    point1 = "-75.12640974398208,-14.69586512288908,0"
    point2 = "-75.11900813118717,-14.6931973885307,0"
    name1 = "point1"
    name2 = "point2"
    result =
      GepKml::GreatCircle.great_circle_coordinates(
        point1,
        point2,
        name1,
        name2,
      )
    expected =
      "-75.12641,-14.695865,0.0 <!-- point1 -->\n-75.119008,-14.693197,0.0 <!-- point2 -->\n104.87359,14.695865,0.0 <!-- point1 antipode -->\n104.880992,14.693197,0.0 <!-- point2 antipode -->\n-75.12641,-14.695865,0.0 <!-- point1 -->"
    assert_equal(result, expected)
  end

  # bundle exec rake test TEST=test/test_great_circle.rb TESTOPTS="--name=test_save! -v"
  def test_save!
    subject = tester.dup
    subject.color = :red
    subject.save!
    refute_nil(subject.filename)
    refute_nil(subject.filepath)
  end

  # bundle exec rake test TEST=test/test_great_circle.rb TESTOPTS="--name=test_color -v"
  def test_color
    subject = tester.dup
    assert_equal(:yellow, subject.color)
    assert_match(/yellowLine/, subject.text)
    assert_match(/7f00ffff/, subject.text)

    subject.color = :red
    assert_equal(:red, subject.color)
    assert_match(/redLine/, subject.text)
    assert_match(/7fff00ff/, subject.text)

    subject.color = :blue
    assert_equal(:blue, subject.color)
    assert_match(/blueLine/, subject.text)
    assert_match(/7fffff00/, subject.text)
  end

  private

  def tester
    @tester ||=
      begin
        pin1 = GepKml::Pin.load("stonehenge")
        pin2 = GepKml::Pin.load("baalbek")
        great_circle = GepKml::GreatCircle.new(pin1, pin2)
      end
  end
end
