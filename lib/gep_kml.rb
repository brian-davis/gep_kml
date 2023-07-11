require "nokogiri"
require "cgi"

require_relative "gep_kml/version"
require_relative "gep_kml/mixins/file_system"
require_relative "gep_kml/mixins/geometry"

require_relative "gep_kml/pin"
require_relative "gep_kml/coordinates"
require_relative "gep_kml/great_circle"

module GepKml
  class Error < StandardError; end

  ROOT_PATH = File.expand_path(File.expand_path("../..", __FILE__))
end
