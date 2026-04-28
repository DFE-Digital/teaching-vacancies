require "log_benchmark"

class Gias::ImportSchoolsAndLocalAuthorities
  SCHOOLS_AND_LOCAL_AUTHORITIES_CSV = "edubasealldata".freeze
  BATCH_SIZE = 100

  include LogBenchmark

  def initialize
    reset_data
  end

  class ImportFailure < StandardError
  end

  def call
    log_benchmark("Importing schools and local authorities") do
      import_errors = Gias::Data.new(SCHOOLS_AND_LOCAL_AUTHORITIES_CSV).each_slice(BATCH_SIZE).flat_map do |group|
        group.each do |row|
          local_authorities.add(group_data(row))
          schools.push(school_data(row))
          memberships.push(membership_data(row))
        end
        import_batch
      end
      raise(ImportFailure, import_errors.map { |x| x.errors.full_messages }) if import_errors.any?
    end
  end

  private

  attr_reader :local_authorities, :schools, :memberships

  def reset_data
    @local_authorities = Set.new # LAs are provided with every school so we can discard duplicates
    @schools = []
    @memberships = []
  end

  # sum doesn't work on arrays the same way it works on Integers
  # rubocop:disable Performance/Sum
  def import_batch
    [import_local_authorities,
     import_schools,
     import_memberships].map(&:failed_instances)
                        .reduce(:+).tap { reset_data }
  end
  # rubocop:enable Performance/Sum

  def import_local_authorities
    SchoolGroup.import(
      local_authorities.to_a,
      on_duplicate_key_update: {
        conflict_target: [:local_authority_code],
        columns: local_authorities.first.keys,
      },
    )
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

  def import_memberships
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
      religious_character: row.fetch("ReligiousCharacter (name)").presence || "None",
      number_of_pupils: row.fetch("NumberOfPupils"),
      school_capacity: row.fetch("SchoolCapacity"),
      trust_school_flag_code: row.fetch("TrustSchoolFlag (code)"),
      trusts_code: row.fetch("Trusts (code)"),
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
