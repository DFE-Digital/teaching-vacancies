require "organisation_import/import_organisation_data"

class ImportSchoolData < ImportOrganisationData
  def run!
    import_data(
      csv_url: "#{GIAS_BASE_URL}edubasealldata#{datestring}.csv",
      csv_file_location: "./tmp/#{datestring}-schools-data.csv",
      method: :create_school_and_local_authority,
    )
  end

  private

  def create_school_and_local_authority(row)
    school = create_organisation(row)

    local_authority = SchoolGroup.find_or_create_by(local_authority_code: row["LA (code)"],
                                                    name: row["LA (name)"],
                                                    group_type: "local_authority")
    membership = SchoolGroupMembership.find_or_create_by(school_id: school.id, school_group_id: local_authority.id)
    membership.update!(do_not_delete: true)
  end

  # No point refactoring this method to be shorter as this class is currently being rewritten elsewhere.
  # rubocop:disable Metrics/MethodLength
  def column_name_mappings
    {
      address: "Street",
      address3: "Address3",
      county: "County (name)",
      detailed_school_type: "TypeOfEstablishment (name)",
      easting: "Easting",
      establishment_status: "EstablishmentStatus (name)",
      local_authority_within: "LA (name)",
      locality: "Locality",
      maximum_age: "StatutoryHighAge",
      minimum_age: "StatutoryLowAge",
      name: "EstablishmentName",
      northing: "Northing",
      phase: "PhaseOfEducation (code)",
      postcode: "Postcode",
      region: "GOR (name)",
      school_type: "EstablishmentTypeGroup (name)",
      town: "Town",
      url: "SchoolWebsite",
    }.freeze
  end
  # rubocop:enable Metrics/MethodLength

  def column_value_transformations
    {
      phase: :to_i,
      url: ->(url) { Addressable::URI.heuristic_parse(url).to_s },
    }
  end

  def set_readable_phases(school)
    school.readable_phases = School::READABLE_PHASE_MAPPINGS[school.phase.to_sym]
  end

  def convert_to_organisation(row)
    school = School.find_or_initialize_by(urn: row["URN"])
    set_properties(school, row)
    set_gias_data_as_json(school, row)
    set_readable_phases(school)
    school.save
    school.vacancies.each(&:set_postcode_from_mean_geolocation!) if school.saved_change_to_geolocation?
    school
  end
end
