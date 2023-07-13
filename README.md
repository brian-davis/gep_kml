**GepKml**

This is a simple Ruby gem I've built to make working with Google Earth Pro (GEP) Keyhole Markup Language (KML) easier.
I'm just a hobbyist, so this is very basic at this point.  There are other more full-featured KML gems [available here](https://rubygems.org/search?query=kml) and I refer you to those for more critical functionality.

**Installation**

This is a version 0 project.  It is not published to RubyGems.  It is subject to change at any time.

This Ruby library reuqires an installed Ruby interpreter.  [This guide](https://gorails.com/setup) may be helpful.

Download the repo code from this Github page into a project directory, cd into the project directory and run `gem install pkg/gem_demo-0.2.3.gem --local`.

Given a properly configured _Rubygems_ set up, this should make a CLI tool available:

```bash
$ gep_kml --help
```

**Usage**

As a `require` Ruby library:

```ruby
>> coordinates =
      GepKml::Coordinates.new(
        { latitude: "51°10′44″N", longitude: "1°49′34″W" },
      )
   pin = GepKml::Pin.build_from_coordinates(coordinates, "Stonehenge")
=>
#<GepKml::Pin:0x0000000104a89558 ...>
>> pin.xml.class
=> Nokogiri::XML::Document
```

As a command-line utility:

```bash
$ bin/gep_kml --help
  NAME:

    gep_kml

  DESCRIPTION:

    Google Earth Pro KML utilities.

  COMMANDS:

    antipode          Generate an antipode point pin KML file.
    decimal_to_degree Converts from decimal format to degree/minutes/seconds format.
    degree_to_decimal Converts from degree/minutes/seconds format to decimal format.
    great_circle      Generate a new line KML file drawing a great circle connection two points.
    help              Display global or [command] help documentation
    pin               Generate a new pin KML file from a coordinates string.

  GLOBAL OPTIONS:

    -h, --help
        Display help documentation

    -v, --version
        Display version information

    -t, --trace
        Display backtrace when an error occurs

  AUTHOR:

    Brian Davis <admin@horizonridge.studio>
```

So, for example, you could visit [geohack.com](https://geohack.toolforge.org/geohack.php?pagename=Stonehenge&params=51_10_44_N_1_49_34_W_type:landmark_region:GB-WIL), select-copy the coordinates text, then `cd` to a directory where you would like to save KML data, and then run this:

```bash
$ gep_kml pin "51° 10′ 44″ N, 1° 49′ 34″ W" stonehenge
```

This would take a coordinates string as the first argument, and a name as the second, and create a `.kml` pin file, which can then be loaded into Google Earth Pro (control-O).
