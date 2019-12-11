class LocationCategory
  class << self
    OUT_OF_SCOPE_REGIONS = ['Wales (pseudo)', 'Not Applicable']
    LONDON_REGION = 'London'
    OUT_OF_SCOPE_COUNTIES = ['Powys', 'Blaenau Gwent']

    def include?(location)
      ALL_LOCATION_CATEGORIES.include?(location.downcase)
    end

    def export
      base_path = Rails.root.join('lib', 'tasks', 'data')

      %w[regions counties boroughs].each do |location_category|
        file_path = base_path.join("#{location_category}.yml")

        File.write(file_path, public_send(location_category).to_yaml)
      end
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
