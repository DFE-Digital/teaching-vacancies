module DistanceHelper
  METRES_PER_MILE = 1609.34

  def convert_miles_to_metres(radius)
    (radius * METRES_PER_MILE).to_i
  end
end
