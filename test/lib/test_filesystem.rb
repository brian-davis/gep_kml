require_relative "../test_helper"

class TestGepKml < Minitest::Test
  def test_save_path
    # TODO: refactor save_path, make consistent with CLI
    assert_match(/gep_kml/, GepKml::FileSystem.save_path)
  end

  def test_save_path_default
    assert_match(/data/, GepKml::FileSystem::DEFAULT_SAVE_PATH)
  end

  def test_set_save_path
    assert_respond_to(GepKml::FileSystem, "save_path=")
  end
end
