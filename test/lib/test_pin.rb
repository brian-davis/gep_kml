require_relative "../test_helper"

# bundle exec rake test TEST=test/lib/test_pin.rb
class TestPin < Minitest::Test
  ### Class methods ###
  def test_load_guard
    assert_nil(GepKml::Pin.load("missing.kml")&.xml)
  end

  def test_load_exists
    assert_kind_of(GepKml::Pin, GepKml::Pin.load("rock_of_gibraltar.kml"))
  end

  def test_load_kml_extension
    assert_kind_of(GepKml::Pin, GepKml::Pin.load("rock_of_gibraltar"))
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_build_from_coordinates -v"
  def test_build_from_coordinates
    # https://www.megalithic.co.uk/article.php?sid=54013
    # Catterick Henge
    # Latitude 54.381838N  Longitude: 1.646771W
    coordinates = GepKml::Coordinates.new({ latitude: 54.381838, longitude: -1.646771 })
    pin = GepKml::Pin.build_from_coordinates(coordinates, "Catterick Henge")
    refute_nil(pin)
    assert_equal("Catterick Henge", pin.name)
    assert_equal("-1.646771,54.381838,0.0", pin.coordinates_tag)
    assert_equal("54.381838,-1.646771,0.0", pin.coordinates.to_human)
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_build_from_coordinates_st_michaels_mt -v"
  def test_build_from_coordinates_st_michaels_mt
    coordinates = GepKml::Coordinates.new({ latitude: 50.116, longitude: -5.4772 })
    pin = GepKml::Pin.build_from_coordinates(coordinates, "St. Michael's Mount")
    refute_nil(pin)
    assert_equal("St. Michael's Mount", pin.name)
    assert_equal("-5.4772,50.116,0.0", pin.coordinates_tag) # GEP: long. first
    assert_equal("50.116,-5.4772,0.0", pin.coordinates.to_human) # normal: lat. first
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_build_from_coordinates_st_michaels_mt_strings -v"
  def test_build_from_coordinates_st_michaels_mt_strings
    coordinates = GepKml::Coordinates.new({ latitude: "50.116", longitude: "-5.4772" })
    pin = GepKml::Pin.build_from_coordinates(coordinates, "St. Michael's Mount")
    refute_nil(pin)
    assert_equal("St. Michael's Mount", pin.name)
    assert_equal("-5.4772,50.116,0.0", pin.coordinates_tag) # GEP: long. first
    assert_equal("50.116,-5.4772,0.0", pin.coordinates.to_human) # normal: lat. first
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_build_from_coordinates_st_michaels_mt_mixup -v"
  def test_build_from_coordinates_st_michaels_mt_mixup
    # "-5.4772, 50.116" # grabbed from pin file (GEP long. first) without correcting
    coordinates = GepKml::Coordinates.new({ latitude: -5.4772, longitude: 50.116 })
    pin = GepKml::Pin.build_from_coordinates(coordinates, "St. Michael's Mount MIXUP")
    refute_nil(pin)
    assert_equal("St. Michael's Mount MIXUP", pin.name)
    assert_equal("50.116,-5.4772,0.0", pin.coordinates_tag) # GEP: long. first
    assert_equal("-5.4772,50.116,0.0", pin.coordinates.to_human) # normal: lat. first
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_build_from_coordinates_string -v"
  def test_build_from_coordinates_string
    # Latitude: 37.024132N  Longitude: 4.548342W
    # Site Name: Cueva de Menga
    # https://www.megalithic.co.uk/article.php?sid=12111
    coordinates = GepKml::Coordinates.new({
      latitude: "37.024132N", longitude: "4.548342W"
    })
    pin = GepKml::Pin.build_from_coordinates(coordinates, "Cueva de Menga")
    refute_nil(pin)
    assert_equal("Cueva de Menga", pin.name)
    assert_equal("-4.548342,37.024132,0.0", pin.coordinates_tag)
    assert_equal("37.024132,-4.548342,0.0", pin.coordinates.to_human)
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_build_from_coordinates_string_degree -v"
  def test_build_from_coordinates_string_degree
    # 51°10′44″N 1°49′34″W
    # https://en.wikipedia.org/wiki/Stonehenge
    coordinates =
      GepKml::Coordinates.new(
        { latitude: "51°10′44″N", longitude: "1°49′34″W" },
      )
    pin = GepKml::Pin.build_from_coordinates(coordinates, "Stonehenge")
    refute_nil(pin)
    assert_equal("-1.826111,51.178889,0.0", pin.coordinates_tag)
    assert_equal("51.178889,-1.826111,0.0", pin.coordinates.to_human)
  end

  ### Instance methods ###
  def test_initialize
    # As in GEP right-click > 'copy'
    filename = "rock_of_gibraltar.kml"
    filepath =
      File.join(GepKml::FileSystem.save_path, "rock_of_gibraltar.kml")
    text = File.read(filepath)
    pin = GepKml::Pin.new(text, filename, filepath)
    assert_kind_of(GepKml::Pin, pin)
    assert_equal(filename, pin.filename)
    assert_equal(filepath, pin.filepath)
  end

  def test_text
    assert_match(/xml version/, pin_fixture.text)
  end

  def test_xml
    xml = pin_fixture.xml
    assert(xml)
  end

  def test_name
    result = pin_fixture.name
    expected = "Rock of Gibraltar"
    assert_equal(expected, result)
  end

  def test_name=
    subject = pin_fixture.dup
    before_name = subject.name
    expected = "Rock of Gibraltar"
    assert_equal(expected, before_name)
    subject.name = "Pillars of Heracles"
    after_name = subject.name
    expected = "Pillars of Heracles"
    assert_equal(expected, after_name)
  end

  def test_coordinates
    result = pin_fixture.coordinates_tag
    expected = "-5.341408478448254,36.14428984494907,0"
    assert_equal(expected, result)
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_to_human! -v"
  def test_to_human
    result = pin_fixture.dup.coordinates.to_human
    expected = "36.14429,-5.341408,0.0"
    assert_equal(expected, result)
  end

  def test_respond_to_save!
    assert_respond_to(pin_fixture, "save!")
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_write_changes_on_save! -v"
  def test_write_changes_on_save!
    subject = pin_fixture.dup
    subject.name = "test1"
    refute_match(/test1/, subject.text)
    subject.save!("test1")
    assert_match(/test1/, subject.text)
    is_file =
      File.exist?(
        File.expand_path(
          File.join(GepKml::FileSystem.save_path, "test1.kml"),
        ),
      )
    assert(is_file)
    new_file = GepKml::Pin.load("test1")
    assert_equal("test1", new_file.name)
  end

  def test_antipode!
    assert_respond_to(pin_fixture, :antipode!)
  end

  def test_set_name_with_antipode!
    subject = pin_fixture.dup
    refute_equal("Antipode of Rock of Gibraltar", subject.name)
    subject.antipode!
    assert_equal("Antipode of Rock of Gibraltar", subject.name)
    # undo
    subject.antipode!
    assert_equal("Rock of Gibraltar", subject.name)
  end

  # bundle exec rake test TEST=test/lib/test_pin.rb TESTOPTS="--name=test_set_coordinates_with_antipode! -v"
  def test_set_coordinates_with_antipode!
    subject = pin_fixture.dup
    assert_equal(
      "-5.341408478448254,36.14428984494907,0",
      subject.coordinates_tag,
    )

    # do
    subject.antipode!
    assert_equal("174.658592,-36.14429,0.0", subject.coordinates_tag)

    # undo
    subject.antipode!
    assert_equal("-5.341408,36.14429,0.0", subject.coordinates_tag)
  end
end
