require "rubygems"
require "pry"
require "commander"
require_relative "../lib/gep_kml"

class GepKmlCLI
  include Commander::Methods

  def run
    program :name, "gep_kml"
    program :version, ::GepKml::VERSION
    program :description, "Google Earth Pro KML utilities."
    program :help, "Author", "Brian Davis <horizonridgestudio@fastmail.com>"

    command :degree_to_decimal do |c|
      c.syntax = "gep_kml degree_to_decimal COORDINATE"
      c.summary = "Converts from degree/minutes/seconds format to decimal format."
      c.description =
        %q(
          Pass a single coordinate as the first argument.

          Coordinates built using single- or double-quotes must be properly escaped, e.g. "6˚23'6\\"S".
          Coordinates copied from Wikipedia use special characters and do not need escaping, e.g. "4°32′46.65″ W"

          For a coordinate pair, see TODO.
        )
      c.example "Wikipedia style",
                %q( gep_kml degree_to_decimal "4°32′46.65″ W" #=> -4.546292 )

      c.action do |args, options|
        result = GepKml::Coordinates.degree_to_decimal(args.shift)
        say result
      end
    end

    command :decimal_to_degree do |c|
      c.syntax = "gep_kml decimal_to_degree [options]"
      c.summary = "Converts from decimal format to degree/minutes/seconds format."
      c.description =
        "
        Pass a single coordinate as the first argument. and option --type with
        'lat', 'latitude', 'lon', or 'longitude'.
        For a coordinate pair, see TODO.
        "

      c.example "example 1",
                %q(gep_kml decimal_to_degree --coordinate -3.55918 --orientation latitude #=> 3°33'33"S)

      c.option "--coordinate NUMERIC",
               Numeric,
               "A decimal number value, e.g. 1.234 or -2, or \"123.456\""

      c.option "--orientation STRING",
               String,
               "The orientation of the line [lat, lon]"
      c.action do |_args, options|
        return unless options.coordinate && options.orientation
        decimal_coordinate = options.coordinate.to_f
        linetype =
          if options.orientation
            case options.orientation.to_s.downcase
            when /lat/
              :latitude
            when /lon/
              :longitude
            end
          end

        result = GepKml::Coordinates.decimal_to_degree(decimal_coordinate, linetype)
        say result
      end
    end

    command :pin do |c|
      c.syntax = "gep_kml pin COORDINATES NAME [options]"
      c.summary = "Generate a new pin KML file from a coordinates string."
      c.description =
        "Pass a properly-escaped string with coordinate data (e.g. grabbed from Geohack), and a name string, to save a new .kml file with KML for a Google Earth pin. If passing a decimal-format argument with a leading minus-sign, the minus sign must be escaped."

      c.example "Geohack degree/minute/second",
                %q(
                  gep_kml pin "51° 10′ 44″ N, 1° 49′ 34″ W" stonehenge
                )

      c.example "Geohack Lat/Lon decimal",
                %q(
                  gep_kml pin "51.178889, -1.826111" stonehenge
                )

      # ruby double escape here.  real usage, use single escape
      c.example "Geohack Lat/Lon decimal with initial negative, requires escape",
                %q(
                  gep_kml pin "\\-5.4772, 50.116" somewhere_tricky
                )
      # TODO
      # c.option "--filename STRING",
      #          String,
      #          "A custom filename for the new file"

      c.action do |args, options|
        # TODO: built for testing.  Refactor as option
        save_dir = ENV["SAVE_DIR"]

        coordinate_str = args.shift.to_s
        return if coordinate_str.empty?
        place_name = args.shift.to_s
        return if place_name.empty?

        # working_filename = GepKml::FileSystem.clean_filename(filename, :load)
        working_dir = save_dir || Dir.pwd # absolute

        # TODO: DRY regexes.
        coordinates = if coordinate_str.match?(/-*\d+\.*\d*,\s-*\d.*\d*/)
          # e.g. "51.178889, -1.826111"
          latitude, longitude = coordinate_str.split(",").map { |str| str.delete(" ").delete("\\") }
          GepKml::Coordinates.new({ latitude: latitude, longitude: longitude })
        else
          # e.g. "51° 10′ 44″ N, 1° 49′ 34″ W"
          GepKml::Coordinates.new({ simple: coordinate_str })
        end

        pin = GepKml::Pin.build_from_coordinates(coordinates, place_name)
        # binding.pry

        pin.filepath = working_dir
        pin.save!

        say "Pin saved to: #{pin.filename}"
      end
    end

    command :antipode do |c|
      c.syntax = "gep_kml antipode FILE_NAME [options]"
      c.summary = "Generate an antipode point pin KML file."
      c.description =
        "
        Reads previously saved KML pin data from the current working directory, and creates a pin for the antipode of that
        pin's coordinate.  The antipode pin will be saved to a new file in the same directory.

        In Google Earth Pro (GEP):
        1. Create a pin for a point of interest on the globe.
        2. Find the new pin in the drawer on the left side of the the app, and right click > 'copy'
        3. Save the KML in the clipboard to a new .kml file in your local filesystem using a raw text editor.
        4. In a terminal, `cd` into that directory and run this command, passing the filename as an option.
        5. A new pin will be saved to a new file.  `ls` to find this file.
        6. Find this file in GEP and command-O or File > 'open', find the new pin, to load into the app.
        "

      c.example "Given a saved pin 'stonehenge.kml':",
                "gep_kml antipode stonehenge #=> antipode_of_stonehenge.kml"

      # c.option "--filename STRING",
      #          String,
      #          "A custom filename for the new file"

      c.action do |args, options|
        # TODO: built for testing.  Refactor as option
        save_dir = ENV["SAVE_DIR"]

        filename = args.shift.to_s
        return if filename.empty?

        working_filename = GepKml::FileSystem.clean_filename(filename, :load)
        working_dir = save_dir || Dir.pwd # absolute

        first_pin = GepKml::Pin.load(working_filename, working_dir)
        first_pin.antipode!
        first_pin.filepath = working_dir
        first_pin.save!

        say "Antipode pin saved to: #{first_pin.filename}"
      end
    end

    command :great_circle do |c|
      c.syntax = "gep_kml great_circle FILENAME1 FILENAME2 [options]"
      c.summary =
        "Generate a new line KML file drawing a great circle connection two points."
      c.description =
        "Pass filenames of two existing .kml files for pins, and a new .kml file with a great circle line will be created."

      c.example "example 1",
                "
                  gep_kml great_circle stonehenge baalbek #=> stonehenge_baalbek_great_circle.kml
                "

      # TODO
      # c.option "--filename STRING",
      #          String,
      #          "A custom filename for the new file"

      c.action do |args, options|
        # TODO: built for testing.  Refactor as option
        save_dir = ENV["SAVE_DIR"]

        file1 = args.shift.to_s
        file2 = args.shift.to_s
        return if file1.empty? || file2.empty?

        working_dir = save_dir || Dir.pwd # absolute

        pin1 = GepKml::Pin.load(file1, working_dir)
        pin2 = GepKml::Pin.load(file2, working_dir)

        great_circle = GepKml::GreatCircle.new(pin1, pin2)
        great_circle.filepath = working_dir
        great_circle.save!

        say "Great Circle saved to: #{great_circle.filename}"
      end
    end

    run!
  end
end
