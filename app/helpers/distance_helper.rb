module DistanceHelper
  METRES_PER_MILE = 1_609

  def convert_miles_to_metres(miles)
    Integer(miles) * METRES_PER_MILE
  end
end
