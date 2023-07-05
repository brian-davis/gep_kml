require 'pry'
require_relative "test_helper"

class TestGemDemoCLI < Minitest::Test
  CLI_EXECUTABLE = File.expand_path(File.join(__dir__, "../bin/gep_kml")).freeze
  TMP_DIR = File.expand_path(File.join(__dir__, "./tmp")).freeze

  def test_cli_call_default
    out, err = capture_subprocess_io do
      system("#{CLI_EXECUTABLE}")
    end

    assert_empty(out)
    assert_equal("invalid command. Use --help for more information", err.strip)
  end

  def test_cli_call_help
    out, err = capture_subprocess_io do
      system("#{CLI_EXECUTABLE} --help")
    end

    assert_match(/gep_kml/, out)
    assert_match(/NAME/, out)
    assert_match(/DESCRIPTION/, out)
    assert_match(/COMMANDS/, out)
    assert_match(/GLOBAL OPTIONS/, out)
    assert_empty(err)
  end

  def test_degree_to_decimal_invalid
    out, err = capture_subprocess_io do
      system("#{CLI_EXECUTABLE} degree_to_decimal")
    end

    assert_empty(out)
    assert_empty(err)
  end

  def test_degree_to_decimal_valid
    command = <<~SHELL.strip
    #{CLI_EXECUTABLE} degree_to_decimal "4°32′46.65″ W"
    SHELL
    out, err = capture_subprocess_io do
      system(command)
    end

    assert_equal("-4.546292", out.strip)
    assert_empty(err)
  end

  def test_decimal_to_degree_invalid
    out, err = capture_subprocess_io do
      system("#{CLI_EXECUTABLE} decimal_to_degree")
    end

    assert_empty(out)
    assert_empty(err)
  end

  def test_decimal_to_degree_valid
    command = <<~SHELL.strip
    #{CLI_EXECUTABLE} decimal_to_degree --coordinate -3.55918 --orientation latitude
    SHELL
    out, err = capture_subprocess_io do
      system(command)
    end

    assert_equal("3°33'33\"S", out.strip)
    assert_empty(err)
  end

  def test_pin_invalid
    out, err = capture_subprocess_io do
      system("#{CLI_EXECUTABLE} pin")
    end

    assert_empty(out)
    assert_empty(err)
  end

  def test_pin_valid_geohack
    command = <<~SHELL.strip
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} pin "51° 10′ 44″ N, 1° 49′ 34″ W" stonehenge
    SHELL

    out, err = capture_subprocess_io do
      system(command)
    end

    assert_equal("Pin saved to: stonehenge.kml", out.strip)
    assert(Dir.entries(TMP_DIR).include?("stonehenge.kml"))
    assert_empty(err)
  ensure
    clear_tmp_files
  end

  # rake test TEST=test/test_gep_kml_cli.rb TESTOPTS="--name=test_pin_valid_geohack_name_with_spaces -v"
  def test_pin_valid_geohack_name_with_spaces
    command = <<~SHELL.strip
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} pin "51° 10′ 44″ N, 1° 49′ 34″ W" "That Stonehenge Place"
    SHELL

    out, err = capture_subprocess_io do
      system(command)
    end

    assert_equal("Pin saved to: that_stonehenge_place.kml", out.strip)
    assert(Dir.entries(TMP_DIR).include?("that_stonehenge_place.kml"))
    assert_empty(err)
  ensure
    clear_tmp_files
  end

  def test_pin_valid_decimal
    command = <<~SHELL.strip
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} pin "51.178889, -1.826111" stonehenge
    SHELL

    out, err = capture_subprocess_io do
      system(command)
    end

    assert_equal("Pin saved to: stonehenge.kml", out.strip)
    assert(Dir.entries(TMP_DIR).include?("stonehenge.kml"))
    assert_empty(err)
  ensure
    clear_tmp_files
  end

  # rake test TEST=test/test_gep_kml_cli.rb TESTOPTS="--name=test_pin_valid_decimal_negative_first_value -v"
  def test_pin_valid_decimal_negative_first_value

    # double escape char here.
    command = <<~SHELL.strip
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} pin "\\-5.4772, 50.116" st_michaels_mt_mixup
    SHELL

    out, err = capture_subprocess_io do
      system(command)
    end
    assert_equal("Pin saved to: st_michaels_mt_mixup.kml", out.strip)
    assert(Dir.entries(TMP_DIR).include?("st_michaels_mt_mixup.kml"))
    refute_equal("invalid option: -5.4772, 50.116", err.strip)
    assert_empty(err)
  ensure
    clear_tmp_files
  end

  def test_antipode_invalid
    out, err = capture_subprocess_io do
      system("#{CLI_EXECUTABLE} antipode")
    end

    assert_empty(out)
    assert_empty(err)
  end

  def test_antipode_valid
    command = <<~SHELL.strip
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} pin "51.178889, -1.826111" stonehenge
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} antipode stonehenge
    SHELL

    out, err = capture_subprocess_io do
      system(command)
    end
    # TODO: fix redundant _kml
    assert_equal("Antipode pin saved to: antipode_of_stonehenge_kml.kml", out.split(/\n/).last.strip)
    assert(Dir.entries(TMP_DIR).include?("antipode_of_stonehenge_kml.kml"))
    assert_empty(err)
  ensure
    clear_tmp_files
  end

  def test_great_circle_invalid
    out, err = capture_subprocess_io do
      system("#{CLI_EXECUTABLE} great_circle")
    end

    assert_empty(out)
    assert_empty(err)
  end

  def test_great_circl_valid
    command = <<~SHELL.strip
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} pin "51.178889, -1.826111" stonehenge
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} pin "35.05,32.733333" "Mt. Carmel"
    SAVE_DIR=#{TMP_DIR} #{CLI_EXECUTABLE} great_circle stonehenge mt__carmel
    SHELL

    out, err = capture_subprocess_io do
      system(command)
    end

    # TODO: fix redundant _kml
    assert_equal("Great Circle saved to: stonehenge_mt__carmel_great_circle.kml", out.split(/\n/).last.strip)
    assert(Dir.entries(TMP_DIR).include?("stonehenge_mt__carmel_great_circle.kml"))
    assert_empty(err)
  ensure
    clear_tmp_files
  end

  private def clear_tmp_files
    Dir.children(TMP_DIR).each do |child|
      filepath = "#{TMP_DIR}/#{child}"
      File.delete(filepath) if File.exist?(filepath)
    end
  end
end
