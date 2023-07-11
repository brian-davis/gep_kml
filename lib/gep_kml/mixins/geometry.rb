module GepKml
  # GepKml::Geometry supports basic geometric calculations.
  module Geometry
    class << self
      # https://www.cuemath.com/geometry/area-of-a-circle/
      # Area = C2/4π
      def circumference_to_area(c)
        π = Math::PI
        (c ** 2) / (4 * π)
      end
    end
  end
end
