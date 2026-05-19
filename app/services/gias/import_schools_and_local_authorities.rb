require "log_benchmark"
require "csv"

class Gias::ImportSchoolsAndLocalAuthorities
  SCHOOLS_AND_LOCAL_AUTHORITIES_CSV = "edubasealldata".freeze
  BATCH_SIZE = 100

  extend LogBenchmark

  class ImportFailure < StandardError
  end

  # New GIAS team now have some data dictionary information available at
  # https://dfedigital.atlassian.net/wiki/spaces/GTP/pages/6155337742/Data+Dictionary
  # but it's not quite complete/definitive
  # (e.g establishment status says open/closed/proposed when reality is 'open proposed to close' and 'proposed to open')
  class << self
    def call
      log_benchmark("Importing schools and local authorities") do
        import_errors = Gias::Data.new(SCHOOLS_AND_LOCAL_AUTHORITIES_CSV).each_slice(BATCH_SIZE).flat_map do |group|
          import_group  group
        end
        raise ImportFailure, import_errors.map(&:errors) if import_errors.any?
      end
    end

    SCHOOL_MAPPINGS = {
      urn: "URN",
      address: "Street",
      county: "County (name)",
      detailed_school_type: "TypeOfEstablishment (name)",
      establishment_status: "EstablishmentStatus (name)",
      local_authority_within: "LA (name)",
      maximum_age: "StatutoryHighAge",
      minimum_age: "StatutoryLowAge",
      name: "EstablishmentName",
      postcode: "Postcode",
      region: "GOR (name)",
      school_type: "EstablishmentTypeGroup (name)",
      town: "Town",
      phase: "PhaseOfEducation (code)",
      url: "SchoolWebsite",
      religious_character: "ReligiousCharacter (name)",
    }.freeze

    private

    # rubocop:disable Metrics/MethodLength
    def import_group(group)
      local_authorities = Set.new # LAs are provided with every school so we can discard duplicates
      schools = []
      memberships = []
      discarded = []

      group.each do |row|
        local_authorities.add(group_data(row))
        school_row = school_data(row)
        schools.push(school_row)
        if school_row.fetch(:school_type).in?(School::EXCLUDED_SCHOOL_TYPES)
           || school_row.fetch(:detailed_school_type).in?(School::OUT_OF_SCOPE_DETAILED_SCHOOL_TYPES)
           || school_row.fetch(:establishment_status).in?(School::CLOSED_ESTABLISHMENT_STATUSES)
          discarded.push(school_row)
        end
        memberships.push(membership_data(row))
      end
      # run each batch in a transaction so that data doesn't get out of sync if something crashes
      School.transaction do
        import_batch(local_authorities, schools, memberships).tap do
          School.where(urn: discarded.map { |school_row| school_row.fetch(:urn) }).discard_all
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def import_batch(local_authorities, schools, memberships)
      import_local_authorities(local_authorities).failed_instances +
        import_schools(schools).failed_instances +
        import_memberships(local_authorities, schools, memberships).failed_instances
    end

    def import_local_authorities(local_authorities)
      SchoolGroup.import(
        local_authorities.to_a,
        on_duplicate_key_update: {
          conflict_target: [:local_authority_code],
          columns: local_authorities.first.keys,
        },
      )
    end

    def import_schools(schools)
      imported_schools = schools.map { |s| s.merge(discarded_at: nil) }
      School.import(
        imported_schools,
        on_duplicate_key_update: {
          conflict_target: [:urn],
          columns: imported_schools.first.keys,
        },
      )
    end

    def import_memberships(local_authorities, schools, memberships)
      school_ids = School.where(urn: schools.map { |s| s[:urn] }).pluck(:urn, :id).to_h
      group_ids = SchoolGroup.where(
        local_authority_code: local_authorities.map { |la| la[:local_authority_code] },
      ).pluck(:local_authority_code, :id).to_h

      school_group_memberships = memberships.map do |m|
        {
          school_id: school_ids[m[:urn]],
          school_group_id: group_ids[m[:local_authority_code]],
          do_not_delete: true,
        }
      end

      SchoolGroupMembership.import(
        school_group_memberships,
        on_duplicate_key_update: {
          conflict_target: %i[school_id school_group_id],
          columns: school_group_memberships.first.keys,
        },
      )
    end

    def group_data(row)
      {
        local_authority_code: row["LA (code)"],
        name: row["LA (name)"],
        group_type: "local_authority",
        gias_data: row.to_h.slice("LA (code)", "LA (name)"),
      }
    end

    def school_data(row)
      SCHOOL_MAPPINGS.to_h { |key, row_key|
        raw_value = row.fetch(row_key)
        value = case key
                when :phase
                  raw_value.to_i
                when :url
                  Addressable::URI.heuristic_parse(raw_value).to_s
                when :religious_character
                  raw_value.presence || "None"
                else
                  raw_value
                end
        [key, value]
      }.merge(gias_data: row.to_h)
                     .merge(school_location_data(row))
                     .transform_values(&:presence)
    end

    def school_location_data(row)
      return {} unless row["Easting"] && row["Northing"]

      uk27700 = GeoFactories::FACTORY_27700.point(row["Easting"].to_i, row["Northing"].to_i)
      {
        uk_geopoint: uk27700,
        geopoint: GeoFactories.convert_sr27700_to_wgs84(uk27700),
      }
    end

    def membership_data(row)
      {
        urn: row["URN"],
        local_authority_code: row["LA (code)"],
      }
    end
  end
end
