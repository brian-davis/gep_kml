module GepKml
  # GepKml::FileSystem supports file read/write operations.
  module FileSystem
    DEFAULT_SAVE_PATH = "data".freeze
    TEMPLATE_PATH = "data_templates".freeze
    TEMPLATES = {
      pin: "pin.kml".freeze,
      line: "line.kml".freeze,
    }.freeze

    class << self
      def save_path
        @save_path ||=
          File.expand_path(File.join(GepKml::ROOT_PATH, DEFAULT_SAVE_PATH))
      end

      def save_path=(path)
        raise GepKml::Error, "dir must exist" unless Dir.exist?(path)
        @save_path = path
      end

      def template_path(template = :pin)
        template_filename = GepKml::FileSystem::TEMPLATES[template]
        # binding.pry
        path =
          File.expand_path(
            File.join(
              GepKml::ROOT_PATH,
              GepKml::FileSystem::TEMPLATE_PATH,
              template_filename,
            ),
          )
        path
      end

      # TODO: DRY, general refactor
      def clean_filename(str, mode = :save)
        save_filename = str.downcase
        save_filename.gsub!(/\W/, "_") if mode == :save
        save_filename += ".kml" if File.extname(save_filename) == ""
        save_filename
      end
    end

    def clean_filename(str, mode = :save)
      save_filename = str.downcase
      save_filename.gsub!(/\W/, "_") if mode == :save
      save_filename += ".kml" if File.extname(save_filename) == ""
      save_filename
    end

    def save_path(save_filename)
      File.expand_path(File.join(GepKml::FileSystem.save_path, save_filename))
    end

    # filename has already been cleaned
    # path has already been expanded
    # TODO: make smarter
    def custom_path(filename, path)
      File.join(path, filename)
    end

    def save_to_file(path, text)
      File.open(path, "w") { |f| f.write(text) }
    end
  end
end
