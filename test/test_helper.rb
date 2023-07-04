require_relative "../lib/gep_kml"

require "minitest/autorun"
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

fixture_path = File.expand_path(File.join(__dir__, "fixtures"))
GepKml::FileSystem.save_path = fixture_path

def pin_fixture
  @pin_fixture ||= GepKml::Pin.load("rock_of_gibraltar.kml")
end
