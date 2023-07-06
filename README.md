**GepKml**

This is a simple Ruby gem I've built to make working with Google Earth Pro (GEP) Keyhole Markup Language (KML) easier.
I'm just a hobbyist, so this is very basic at this point.  There are other more full-featured KML gems [available here](https://rubygems.org/search?query=kml) and I refer you to those for more critical functionality.

**Installation**

This is a version 0 project.  It is not published to RubyGems.  It is subject to change at any time.

Download from this Github page, cd into the project directory and run `bundle install`.

To view docs:

```bash
$ yardoc
$ yard server
```

Then open a browser window at `localhost:8808`.

**Usage**

```ruby
>> coordinates =
      KmlUtils::Coordinates.new(
        { latitude: "51°10′44″N", longitude: "1°49′34″W" },
      )
   pin = KmlUtils::Pin.build_from_coordinates(coordinates, "Stonehenge")
=>
#<KmlUtils::Pin:0x0000000104a89558 ...>
>> pin.xml.class
=> Nokogiri::XML::Document
```

See YARD docs for full documentation of classes and modules.

There is also command-line usage:

```bash
$ bin/gep_kml --help

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
