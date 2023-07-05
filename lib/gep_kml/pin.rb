module GepKml
  # GepKml::Pin models a pushpin created in Google Earth Pro (GEP).
  # In Google Earth Pro, save a location with a pin, then right-click > copy.
  # GEP-generated KML (XML) will be copied to the clipboard.  A GepKml::Pin
  # object is initialized with this data.
  class Pin
    include GepKml::FileSystem

    class << self
      # Load raw kml from a .kml saved to a new Pin.
      # filename arg must be an existing file with .kml extension
      def load(filename, path = "")
        pin = new()
        pin.load_from_file!(filename, path)
        pin
      end

      # Create a new Pin with raw coordinate data, without existing KML data.
      def build_from_coordinates(coordinates, name = nil)
        return unless coordinates.is_a?(GepKml::Coordinates)
        pin = new()
        pin.load_from_template!
        pin.coordinates = coordinates
        pin.name = name
        pin
      end
    end

    attr_accessor :filename, :filepath
    attr_accessor :text

    # Builds a Pin with KML data as a string.
    def initialize(text = nil, filename = nil, filepath = nil)
      @text = text
      @filename = filename
      @filepath = filepath
    end

    # Read the most specific <name> tag
    def name
      xml.css("Document Placemark name")&.first&.content
    end

    # Set both <name> tags
    def name=(new_name)
      xml.css("name").each { |x| x.content = new_name }
    end

    # Extracts coordinate data from previously-loaded KML.
    #
    # == Returns:
    # A memoized string with coordinates in default longitude, latitude,
    # altitude (decimal) format:
    # `=> "-75.12640974398208,-14.69586512288908,0"`
    def coordinates_tag
      xml.css("Document Placemark coordinates")&.first&.text
    end

    # Set both <name> tags
    alias_method :coordinates=, def coordinates_tag=(new_coordinates)
      return unless new_coordinates.is_a?(GepKml::Coordinates)
      xml
        .css("Placemark Point coordinates")
        .each { |x| x.content = new_coordinates.to_s }
      xml
        .css("Placemark LookAt longitude")
        .each { |x| x.content = new_coordinates.longitude }
      xml
        .css("Placemark LookAt latitude")
        .each { |x| x.content = new_coordinates.latitude }
    end

    def coordinates
      GepKml::Coordinates.new(kml_csv: self.coordinates_tag)
    end

    # A memoized reader for parsed KML data built from
    # previously-loaded text.
    #
    # == Returns:
    # A Nokogiri object with parsed KML (XML) data.
    alias_method :kml,
                 def xml
                   return unless text
                   @xml ||= Nokogiri.parse(text)
                 end

    # no path param here; set desired save path directly in separate call.
    def save!(new_filename = nil)
      save_filename = new_filename || filename || name
      return unless save_filename
      self.filename = clean_filename(save_filename)
      self.text = self.xml.to_s

      # TODO: DRY
      if self.filepath && !File.directory?(self.filepath)
        self.filepath = File.split(self.filepath).first
      end

      new_file = if self.filepath.nil?
        # fallback to default save path (app-level config)
        save_path(self.filename)
      else
        File.join(self.filepath, self.filename)
      end
      #=> "/path/to/file.kml"

      save_to_file(new_file, self.text) and new_file
    end

    def load_from_file!(filename, path = "")
      filename = clean_filename(filename, :load)
      filepath =
        (path.empty? ? save_path(filename) : custom_path(filename, path))
      return unless File.exist?(filepath)
      self.text = File.read(filepath)
      self.filename = filename
      self.filepath = filepath
      @xml = Nokogiri.parse(self.text)
    end

    def load_from_template!
      filepath = GepKml::FileSystem.template_path(:pin)
      self.text = File.read(filepath)
      @xml = Nokogiri.parse(text)
    end

    def antipode!
      case self.name
      when /Antipode of /
        # 2nd run, undo
        self.name = self.name.sub("Antipode of ", "")
      else
        # 1st run
        self.name = "Antipode of #{self.name}"
      end

      antipode = self.coordinates.antipode!
      self.coordinates_tag = antipode

      # set up .save!
      self.filename = clean_filename(name)
      self.filepath = nil
      return nil
    end
  end
end
