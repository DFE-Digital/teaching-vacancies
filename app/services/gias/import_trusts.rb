require "log_benchmark"
require "geocoding"

class Gias::ImportTrusts
  TRUSTS_CSV = "allgroupsdata".freeze
  TRUST_MEMBERSHIPS_CSV = "alllinksdata".freeze

  include LogBenchmark

  def initialize
    @trusts = []
    @memberships = []

    @existing_trust_postcodes = SchoolGroup.trusts.pluck(:uid, :postcode).to_h
  end

  def call
    load_data

    import_trusts
    import_memberships
    update_geolocation_for_changed_postcodes unless DisableExpensiveJobs.enabled?
  end

  private

  attr_reader :trusts, :memberships, :existing_trust_postcodes

  def load_data
    log_benchmark("Downloading and parsing CSVs") do
      Gias::Data.new(TRUSTS_CSV).each do |row|
        next unless multi_academy_trust_data?(row)

        trusts.push(trust_data(row))
      end

      Gias::Data.new(TRUST_MEMBERSHIPS_CSV).each do |row|
        next unless multi_academy_trust_data?(row)

        memberships.push(membership_data(row))
      end
    end
  end

  def import_trusts
    log_benchmark("Importing #{trusts.count} trusts") do
      SchoolGroup.import(
        trusts,
        on_duplicate_key_update: {
          conflict_target: [:uid],
          columns: trusts.first.keys,
        },
      )
    end
  end

  def import_memberships # rubocop:disable Metrics/MethodLength
    log_benchmark("Importing #{memberships.count} trust memberships") do
      school_ids = School.pluck(:urn, :id).to_h
      group_ids = SchoolGroup.pluck(:uid, :id).to_h

      school_group_memberships = memberships.filter_map do |m|
        school_id = school_ids[m[:urn]]
        group_id = group_ids[m[:uid]]
        next unless school_id && group_id

        {
          school_id: school_id,
          school_group_id: group_id,
          do_not_delete: true,
        }
      end

      unless school_group_memberships.none?
        SchoolGroupMembership.import(
          school_group_memberships,
          on_duplicate_key_update: {
            conflict_target: %i[school_id school_group_id],
            columns: school_group_memberships.first.keys,
          },
        )
      end
    end
  end

  def update_geolocation_for_changed_postcodes
    # TODO: This is the slowest part of the whole import flow, and should be moved into individual
    #       background jobs in the future
    log_benchmark("Updating geolocation for #{trusts_with_changed_postcode.size} trusts with new or changed postcodes") do
      postcode_updates = trusts_with_changed_postcode.filter_map { |trust|
        coordinates = Geocoding.new(trust[:postcode]).coordinates
        next if coordinates == [0, 0]

        {
          uid: trust[:uid],
          geopoint: "POINT(#{coordinates.second} #{coordinates.first})",
        }
      }.compact

      unless postcode_updates.none?
        SchoolGroup.import(
          postcode_updates,
          on_duplicate_key_update: {
            conflict_target: [:uid],
            columns: postcode_updates.first.keys,
          },
        )
      end
    end
  end

  def multi_academy_trust_data?(row)
    # The CSVs contain data for multiple types of school, but we are only interested in
    # Multi Academy trusts, so we filter by their GIAS Group Type
    row["Group Type (code)"].to_i == 6
  end

  def trust_data(row)
    {
      uid: row["Group UID"],
      name: row["Group Name"].titlecase,
      address: row["Group Locality"],
      county: row["Group County"],
      group_type: row["Group Type"],
      town: row["Group Town"],
      postcode: row["Group Postcode"],
      gias_data: row.to_h,
    }
  end

  def membership_data(row)
    {
      uid: row["Group UID"],
      urn: row["URN"],
    }
  end

  def trusts_with_changed_postcode
    @trusts_with_changed_postcode ||= trusts.reject do |trust|
      trust[:postcode] == existing_trust_postcodes[trust[:uid]]
    end
  end
end
