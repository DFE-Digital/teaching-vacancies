module Backfills
  class VacancyGeolocation
    def self.call
      Vacancy.where(geolocation: nil).find_each do |v|
        v.send(:refresh_geolocation)
        v.save!(touch: false, validate: false)
      end
    end
  end
end
