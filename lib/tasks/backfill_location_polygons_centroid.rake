namespace :location_polygons do
  desc "Computes and set centroid on location polygons containing an area but no centroid"
  task backfill_centroid: :environment do
    LocationPolygon.where.not(area: nil).where(centroid: nil).update_all("centroid = ST_Centroid(area)")
  end
end
