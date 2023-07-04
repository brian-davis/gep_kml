module GepKml
  # GepKml::GreatCircle models a great circle, i.e. the longest line circling the globe
  # connecting two points.
  class GreatCircle
    include GepKml::FileSystem

    class << self
      # Generate a five-segment line to draw a great cirlce overlaying two given points.
      #
      # ```
      # > coordinate1 = "-75.12640974398208,-14.69586512288908,0"
      # > coordinate2 = "-75.11900813118717,-14.6931973885307,0"
      # > puts GepKml.great_circle_coordinates(coordinate1, coordinate2)
      # -75.12640974398208,-14.69586512288908,0 <!-- coordinate1 -->
      # -75.11900813118717,-14.6931973885307,0 <!-- coordinate2 -->
      # 104.87359025601792,14.69586512288908,0.0 <!-- coordinate1 antipode -->
      # 104.88099186881283,14.6931973885307,0.0 <!-- coordinate2 antipode -->
      # -75.12640974398208,-14.69586512288908,0 <!-- coordinate1 -->
      # => nil
      # ```
      def great_circle_coordinates(
        coord1,
        coord2,
        name1 = "coordinate1",
        name2 = "coordinate2"
      )
        coordinate1 =
          (
            if coord1.is_a?(GepKml::Coordinates)
              coord1
            else
              GepKml::Coordinates.new(kml_csv: coord1)
            end
          )

        coordinate2 =
          (
            if coord2.is_a?(GepKml::Coordinates)
              coord2
            else
              GepKml::Coordinates.new(kml_csv: coord2)
            end
          )

        antipode1 = coordinate1.dup.antipode!

        antipode2 = coordinate2.dup.antipode!

        [
          "#{coordinate1} <!-- #{name1} -->",
          "#{coordinate2} <!-- #{name2} -->",
          "#{antipode1} <!-- #{name1 + " antipode"} -->",
          "#{antipode2} <!-- #{name2 + " antipode"} -->",
          "#{coordinate1} <!-- #{name1} -->",
        ].join("\n")
      end
    end

    attr_accessor :pin1, :pin2, :filename, :filepath

    LINE_COLORS = { yellow: "7f00ffff", red: "7fff00ff", blue: "7fffff00" }

    def initialize(pin1, pin2)
      @pin1 = pin1
      @pin2 = pin2
      @filename = nil
      @filepath = nil
      # initialize with pin values
      _xml = xml
      _coordinates = coordinates
    end

    def xml
      # initialize, read from template
      @xml ||= Nokogiri.parse(text)
    end

    def text
      @text ||=
        begin
          # filename = clean_filename("line_template", :load)
          filepath = GepKml::FileSystem.template_path(:line)
          raise GepKml::Error, "missing template" unless File.exist?(filepath)
          File.read(filepath)
        end
    end

    def name
      xml.css("Document name")&.first&.content
    end

    def name=(new_name)
      xml.css("Document name").each { |x| x.content = new_name }
    end

    def coordinates
      @coordinates ||= set_coordinates
    end

    def save!(new_filename = nil)
      save_filename = new_filename || self.filename || self.name
      return unless save_filename
      @filename = clean_filename(save_filename)

      self.filepath =
        if self.filepath.nil?
          save_path(self.filename)
        else
          File.join(self.filepath, self.filename)
        end

      @text = CGI.unescapeHTML(self.xml.to_s)
      save_to_file(self.filepath, self.text)
    end

    def color
      LINE_COLORS.key(xml.css("Document Style LineStyle color")&.first&.content)
    end

    def color=(colorname)
      xml.css("Document Style LineStyle color")&.first&.content =
        LINE_COLORS[colorname]

      @xml.css("Document Style").first.attributes.first[1].value =
        begin
          "#{colorname}Line"
        rescue StandardError
          nil
        end

      @text = CGI.unescapeHTML(@xml.to_s)
    end

    private def set_coordinates
      new_coordinates =
        self.class.great_circle_coordinates(
          pin1.coordinates_tag,
          pin2.coordinates_tag,
          pin1.name,
          pin2.name,
        )

      xml.css("Document Placemark LineString coordinates")&.first&.content =
        new_coordinates

      self.name = "#{pin1.name}-#{pin2.name} Great Circle"

      @text = CGI.unescapeHTML(@xml.to_s)

      return new_coordinates
    end
  end
end
