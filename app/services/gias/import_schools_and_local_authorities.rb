require "log_benchmark"
require "csv"

class Gias::ImportSchoolsAndLocalAuthorities
  SCHOOLS_AND_LOCAL_AUTHORITIES_CSV = "edubasealldata".freeze
  BATCH_SIZE = 100

  extend LogBenchmark

  class ImportFailure < StandardError
  end

  class << self
    def call
      # This file is a list of colleges in-scope for FE vacancies on TVS
      uk_colleges = CSV.read(Rails.root.join("config/data/colleges.csv"), headers: true).index_by { |r| r.fetch("UKPRN").to_i }.transform_values(&:to_h)

      log_benchmark("Importing schools and local authorities") do
        Gias::Data.new(SCHOOLS_AND_LOCAL_AUTHORITIES_CSV).each_slice(BATCH_SIZE) do |group|
          import_group uk_colleges, group
        end
      end
    end

    private

    def import_group(uk_colleges, group)
      local_authorities = Set.new # LAs are provided with every school so we can discard duplicates
      schools = []
      memberships = []
      discarded = []

      group.each do |row|
        local_authorities.add(group_data(row))
        school_row = school_data(row)
        schools.push(school_row)
        if (school_row.fetch(:school_type) == "College" && school_row.fetch(:detailed_school_type) == "Further education" && uk_colleges.exclude?(school_row.fetch(:uk_prn)))
           || school_row.fetch(:school_type).in?(School::EXCLUDED_SCHOOL_TYPES)
           || school_row.fetch(:establishment_status) == "Closed"
          discarded.push(school_row)
        end
        memberships.push(membership_data(row))
      end
      import_local_authorities(local_authorities) if local_authorities.any?
      import_schools(schools) if schools.any?
      import_memberships(local_authorities, schools, memberships) if memberships.any?
      discarded.each { |school_row| School.find_by!(urn: school_row.fetch(:urn)).discard }
    end

    def import_batch
      import_local_authorities.failed_instances +
        import_schools.failed_instances +
        import_memberships.failed_instances
    end

    def import_local_authorities(local_authorities)
      import = SchoolGroup.import(
        local_authorities.to_a,
        on_duplicate_key_update: {
          conflict_target: [:local_authority_code],
          columns: local_authorities.first.keys,
        },
      )
      raise "Import failed" if import.failed_instances.any?
    end

    def import_schools
      School.import(
        schools,
        on_duplicate_key_update: {
          conflict_target: [:urn],
          columns: schools.first.keys,
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
          school_id: school_ids.fetch(m.fetch(:urn)),
          school_group_id: group_ids.fetch(m.fetch(:local_authority_code)),
          do_not_delete: true,
        }
      end
      # school_group_memberships = memberships.map do |m|
      #   {
      #     school_id: school_ids[m[:urn]],
      #     school_group_id: group_ids[m[:local_authority_code]],
      #     do_not_delete: true,
      #   }
      # end

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

    def school_data(row) # rubocop:disable Metrics/MethodLength
      {
        urn: row["URN"],
        address: row["Street"],
        address3: row["Address3"],
        county: row["County (name)"],
        detailed_school_type: row["TypeOfEstablishment (name)"],
        establishment_status: row["EstablishmentStatus (name)"],
        local_authority_within: row["LA (name)"],
        locality: row["Locality"],
        maximum_age: row["StatutoryHighAge"],
        minimum_age: row["StatutoryLowAge"],
        name: row["EstablishmentName"],
        postcode: row["Postcode"],
        region: row["GOR (name)"],
        school_type: row["EstablishmentTypeGroup (name)"],
        town: row["Town"],
        phase: row["PhaseOfEducation (code)"].to_i,
        url: Addressable::URI.heuristic_parse(row["SchoolWebsite"]).to_s,
        uk_prn: row["UKPRN"].to_i,
        gias_data: row.to_h,
        religious_character: row["ReligiousCharacter (name)"],
      }.merge(school_location_data(row)).transform_values(&:presence)
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
