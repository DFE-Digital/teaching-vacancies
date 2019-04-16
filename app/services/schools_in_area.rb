class SchoolsInArea
  attr_reader :lat, :lng, :radius

  def initialize(lat:, lng:, radius:)
    @lat = lat
    @lng = lng
    @radius = radius
  end

  def results
    schools.each_slice(25).map do |school_slice|
      filter_schools_by_distance(school_slice)
    end.flatten
  end

  private

  def filter_schools_by_distance(schools)
    schools.select do |s|
      place = find_school_from_place(s)
      distance_in_miles(place.distance_in_meters) <= radius
    end
  end

  def find_school_from_place(school)
    data.find { |d| d.destination == school.place }
  end

  def distance_in_miles(metres)
    metres * 0.00062137
  end

  def schools
    @schools ||= School.within(radius, origin: [lat, lng])
                       .joins(:vacancies)
                       .merge(Vacancy.live)
                       .distinct
                       .order(:id)
  end

  def matrix
    @matrix ||= begin
      matrix = GoogleDistanceMatrix::Matrix.new
      matrix.origins << GoogleDistanceMatrix::Place.new(lat: lat, lng: lng)
      schools.each do |s|
        matrix.destinations << s.place
      end
      matrix
    end
  end

  def data
    @data ||= matrix.data.first
  end
end