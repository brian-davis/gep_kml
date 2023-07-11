require_relative "../test_helper"

class TestGepKml < Minitest::Test
  def test_circumference_to_area
    # https://www.cuemath.com/geometry/area-of-a-circle/
    expected = 616.2479396518188
    assert_equal(expected, GepKml::Geometry.circumference_to_area(88))
  end
end
