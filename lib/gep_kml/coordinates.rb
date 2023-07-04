module GepKml
  # GepKml::Coordinates models a latitude/longitude pair, with the string representation
  # being comaptible with long/lat format used in GEP <coordinates> tags.
  class Coordinates
    class << self
      # Convert from degree/minute/second format to decimal.
      #  "6˚23'6\"S"
      # => "-6.385"
      def degree_to_decimal(degree_coordinate)
        degree_coordinate = degree_coordinate.to_s
        degree_regexp = /(-*\d+[º°oO˚])(\d+['′])*(\d+\.*\d*["″])*\s*([NSEW])*/
        degree, minute, second, cardinal =
          degree_coordinate.match(degree_regexp)&.captures
        return unless degree
        degree = degree.to_i
        degree *= -1 if degree.positive? && %w[S W].include?(cardinal)
        if minute || second
          decimal_minute = minute.to_f / 60.0 if minute
          decimal_second = second.to_f / 3600.0 if second
          decimal = (decimal_minute.to_f + decimal_second.to_f).round(6)
          decimal == 0 ? "#{degree}" : "#{degree}#{decimal.to_s.sub("0", "")}"
        else
          "#{degree}"
        end
      rescue StandardError => e
        # TODO
        raise GepKml::Error.new("Something went wrong: #{e.message}")
      end

      # Convert from decimal to degree/minute/second format.
      # "6.385"
      # => "6˚23'6\""
      def decimal_to_degree(decimal_coordinate, linetype = nil)
        decimal_coordinate = decimal_coordinate.to_s
        degree, decimal = decimal_coordinate.split(".")
        degree = degree.to_i
        decimal = "0.#{decimal}".to_f
        minute = (decimal * 60).to_i
        second_decimal = (decimal * 60) - (decimal * 60).to_i
        second = (second_decimal * 60).round(1)
        second = second.to_i if second == second.to_i
        cardinal =
          if linetype && %w[lon long longitude].include?(linetype.to_s)
            degree.negative? ? "W" : "E"
          elsif linetype && %w[lat latitude].include?(linetype.to_s)
            degree.negative? ? "S" : "N"
          end
        degree = degree.abs if cardinal # make positive
        values = [degree, "°", minute, "'", second, "\"", cardinal]
        values.compact.join
      end

      # "37°01′28.51″N" => 37.024132
      # 37.024132 => 37.024132
      def force_decimal(coord)
        coord_str = coord.to_s
        case coord_str
        when /\d+[º°oO˚'′"″]+/
          degree_to_decimal(coord_str)
        when /\d+\.*\d*/
          degree, cardinal = coord_str.match(/(-*\d+\.*\d*)([NSEW])*/)&.captures
          return unless degree
          degree = degree.to_f
          degree *= -1 if degree.positive? && %w[S W].include?(cardinal) # TODO: DRY
          degree.to_s
        else
          nil
        end
      end
    end

    attr_reader :latitude, :longitude, :altitude, :kml_csv

    def initialize(options = {})
      if options[:kml_csv]
        init_from_kml_csv(options)
      elsif options[:simple]
        init_from_simple(options)
      elsif options[:latitude] && options[:longitude]
        init_from_lat_lon(options)
      end
    end

    # Generate coordinates for the antipodal (opposite) point of a given point on the globe.
    # input: "-75.12640974398208,-14.69586512288908,0"
    # output: "104.87359025601792,14.69586512288908,0.0"
    def antipode!
      @longitude =
        (
          if @longitude <= 0.0
            (@longitude + 180.0)
          else
            (@longitude - 180.0)
          end
        )
      @latitude = @latitude * -1
      @kml_csv = nil
      return self
    end

    # input comma-separated coordinate-string,
    # output comma-separated coordinate-string with standardized float rounding.
    # format used in GEP <coordinates> tags
    def to_s
      [
        self.longitude.round(6).to_s,
        self.latitude.round(6).to_s,
        self.altitude.round(6).to_s,
      ].join(",")
    end

    # Converts coordinate data from the default longitude, latitude,
    # altitude (decimal) format in the previously-loaded KML
    # into a more conventional format
    # useful for pasting into the search form in the Google Earth
    # (pro or web) GUI.  The 'human-readable' format is reversed from the KML format.
    #
    # == Returns:
    # A string in format latitude, longitude, altitude
    # > "-75.12640974398208,-14.69586512288908,0"`
    # `=>  "-14.695865,-75.12641,0"`
    def to_human
      [
        self.latitude.round(6).to_s,
        self.longitude.round(6).to_s,
        self.altitude.round(6).to_s,
      ].join(",")
    end

    private

    # If provided with a comma-separated value, as in a GEP <coordinates> tag.
    # overwrite any duplicate values previously provided
    def init_from_kml_csv(options)
      @kml_csv = options[:kml_csv].to_s
      # return if @kml_csv.nil? || @kml_csv.length == 0 # TODO: regex
      return unless [2, 3].include? @kml_csv.split(",").size
      longitude, latitude, altitude = @kml_csv.split(",")
      @longitude = self.class.force_decimal(longitude)&.to_f
      @latitude = self.class.force_decimal(latitude)&.to_f
      @altitude = altitude.to_f.round(6)
    end

    def init_from_simple(options)
      split_tmp = options[:simple].split
      lat = split_tmp[0..split_tmp.length / 2 - 1]
      lon = split_tmp[split_tmp.length / 2..-1]
      @latitude = self.class.force_decimal(lat.join)&.to_f
      @longitude = self.class.force_decimal(lon.join)&.to_f
      @altitude = (options[:altitude] || "0").to_f&.round(6)
    end

    def init_from_lat_lon(options)
      @latitude = self.class.force_decimal(options[:latitude])&.to_f
      @longitude = self.class.force_decimal(options[:longitude])&.to_f
      @altitude = (options[:altitude] || "0").to_f&.round(6)
    end
  end
end
