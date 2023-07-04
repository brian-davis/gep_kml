require_relative "test_helper"

class TestGepKml < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GepKml::VERSION
  end
end
