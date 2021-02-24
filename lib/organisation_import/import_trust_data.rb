require "organisation_import/import_organisation_data"

class ImportTrustData < ImportOrganisationData
  private

  def column_name_mappings
    {
      name: "Group Name",
      address: "Group Locality",
      county: "Group County",
      group_type: "Group Type",
      town: "Group Town",
    }.freeze
  end

  def column_value_transformations
    {
      name: :titlecase,
    }
  end

  def convert_to_organisation(row)
    return unless data_is_for_multi_academy_trust?(row)

    trust = SchoolGroup.find_or_initialize_by(uid: row["Group UID"])
    set_properties(trust, row)
    set_gias_data_as_json(trust, row)
    set_geolocation(trust, row["Group Postcode"])
    trust
  end

  def create_school_group_membership(row)
    return unless data_is_for_multi_academy_trust?(row)

    trust = SchoolGroup.find_by(uid: row["Group UID"])
    school = School.find_by(urn: row["URN"])

    return unless trust.present? && school.present?

    membership = SchoolGroupMembership.find_or_create_by(school_id: school.id, school_group_id: trust.id)
    membership.update!(do_not_delete: true)
  end

  def data_is_for_multi_academy_trust?(row)
    row["Group Type (code)"].to_i == 6
  end

  def set_geolocation(trust, postcode)
    # We don't need to make an API request if the postcode hasn't changed
    return unless postcode.present? && (trust.geolocation.blank? || trust.postcode != postcode)

    trust.postcode = postcode
    coordinates = Geocoding.new(trust.postcode).coordinates
    trust.geolocation = coordinates unless coordinates == [0, 0]
  end

  def csv_metadata
    [trust_csv_metadata, membership_csv_metadata]
  end

  def trust_csv_metadata
    { csv_url: "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata#{datestring}.csv",
      csv_file_location: "./tmp/school-group-data.csv",
      method: :create_organisation }
  end

  def membership_csv_metadata
    { csv_url: "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/alllinksdata#{datestring}.csv",
      csv_file_location: "./tmp/school-group-membership-data.csv",
      method: :create_school_group_membership }
  end
end
