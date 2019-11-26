class LocationCategory
  class << self
    OUT_OF_SCOPE_REGIONS = ['Wales (pseudo)', 'Not Applicable']
    LONDON_REGION = 'London'
    OUT_OF_SCOPE_COUNTIES = ['Powys', 'Blaenau Gwent']

    def all
      regions + boroughs + counties
    end

    def include?(location)
      ALL_LOCATION_CATEGORIES.include?(location.downcase)
    end

    def export
      file_path = Rails.root.join('lib', 'tasks', 'data', 'location_categories.yml')
      location_categories = all.map(&:downcase).sort.to_yaml
      File.write(file_path, location_categories)
    end

    def regions
      Region.where.not(name: OUT_OF_SCOPE_REGIONS)
            .pluck(:name)
    end

    def boroughs
      School.joins(:region)
            .where(regions: { name: LONDON_REGION })
            .group(:local_authority)
            .order(:local_authority)
            .pluck(:local_authority)
    end

    def counties
      School.joins(:region)
            .where.not(regions: { name: OUT_OF_SCOPE_REGIONS + [LONDON_REGION] })
            .where.not(county: OUT_OF_SCOPE_COUNTIES)
            .group(:county)
            .order(:county)
            .pluck(:county)
    end
  end
end
