class ConvertLondonBoroughLocationPolygonsToCountyLocationPolygons < ActiveRecord::Migration[6.1]
  def change
    LocationPolygon.where(location_type: "london_boroughs").each do |borough|
      borough.update!(location_type: 'counties')
    end
  end
end
