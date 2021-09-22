require "log_benchmark"

class Gias::ImportSchoolsAndLocalAuthorities
  SCHOOLS_AND_LOCAL_AUTHORITIES_CSV = "edubasealldata".freeze

  include LogBenchmark

  def initialize
    @local_authorities = []
    @schools = []
    @memberships = []
  end

  def call
    load_data

    import_local_authorities
    import_schools
    import_memberships
  end

  private

  attr_reader :local_authorities, :schools, :memberships

  def load_data
    log_benchmark("Downloading and parsing CSV") do
      Gias::Data.new(SCHOOLS_AND_LOCAL_AUTHORITIES_CSV).each do |row|
        local_authorities.push(group_data(row))
        schools.push(school_data(row))
        memberships.push(membership_data(row))
      end
    end
  end

  def import_local_authorities
    unique_local_authorities = local_authorities.uniq

    log_benchmark("Importing #{unique_local_authorities.size} LAs into database") do
      SchoolGroup.import(
        unique_local_authorities,
        on_duplicate_key_update: {
          conflict_target: [:local_authority_code],
          columns: local_authorities.first.keys,
        },
      )
    end
  end

  def import_schools
    log_benchmark("Importing #{schools.size} schools into database") do
      School.import(
        schools,
        on_duplicate_key_update: {
          conflict_target: [:urn],
          columns: schools.first.keys,
        },
        batch_size: 1000,
      )
    end
  end

  def import_memberships
    log_benchmark("Importing #{memberships.size} school LA memberships") do
      school_ids = School.pluck(:urn, :id).to_h
      group_ids = SchoolGroup.pluck(:local_authority_code, :id).to_h

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
  end

  def group_data(row)
    {
      local_authority_code: row["LA (code)"],
      name: row["LA (name)"],
      group_type: "local_authority",
    }
  end

  def school_data(row)
    phase_number = row["PhaseOfEducation (code)"].to_i
    phase_symbol = School.phases.key(phase_number).to_sym

    {
      urn: row["URN"],
      address: row["Street"],
      address3: row["Address3"],
      county: row["County (name)"],
      detailed_school_type: row["TypeOfEstablishment (name)"],
      easting: row["Easting"],
      establishment_status: row["EstablishmentStatus (name)"],
      local_authority_within: row["LA (name)"],
      locality: row["Locality"],
      maximum_age: row["StatutoryHighAge"],
      minimum_age: row["StatutoryLowAge"],
      name: row["EstablishmentName"],
      northing: row["Northing"],
      postcode: row["Postcode"],
      region: row["GOR (name)"],
      school_type: row["EstablishmentTypeGroup (name)"],
      town: row["Town"],
      phase: phase_number,
      readable_phases: School::READABLE_PHASE_MAPPINGS[phase_symbol],
      url: Addressable::URI.heuristic_parse(row["SchoolWebsite"]).to_s,
      gias_data: row.to_h,
    }.transform_values(&:presence)
  end

  def membership_data(row)
    {
      urn: row["URN"],
      local_authority_code: row["LA (code)"],
    }
  end
end
