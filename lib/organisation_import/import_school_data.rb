require "organisation_import/import_organisation_data"

class ImportSchoolData < ImportOrganisationData
  READABLE_PHASE_MAPPINGS = School::READABLE_PHASE_MAPPINGS

  def run!
    save_csv_file(csv_url, csv_file_location)
    CSV.foreach(csv_file_location, headers: true, encoding: "windows-1252:utf-8").each do |row|
      Organisation.transaction do
        school = create_organisation(row)

        next unless school_in_local_authority_scope?(row)

        local_authority = SchoolGroup.find_or_create_by(local_authority_code: row["LA (code)"],
                                                        name: row["LA (name)"],
                                                        group_type: "local_authority")
        SchoolGroupMembership.find_or_create_by(school_id: school.id, school_group_id: local_authority.id)
      end
    end
    File.delete(csv_file_location)
  end

private

  # These are the attributes that require additional transformation before being added to the model. The first value of
  # the array is the row key name, the second is the method used for the transformation. URL is the exception, as it
  # requires an external function call - this is handled in the set_complex_properties method.
  def complex_mappings
    {
      address3: ["Address3", :presence],
      county: ["County (name)", :presence],
      locality: ["Locality", :presence],
      phase: ["PhaseOfEducation (code)", :to_i],
      url: ["SchoolWebsite", nil],
    }.freeze
  end

  def convert_to_organisation(row)
    school = School.find_or_initialize_by(urn: row["URN"])
    set_complex_properties(school, row)
    set_simple_properties(school, row)
    set_gias_data_as_json(school, row)
    set_readable_phases(school)
    school
  end

  def csv_file_location
    "./tmp/#{datestring}-schools-data.csv"
  end

  def csv_url
    "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv"
  end

  def datestring
    Time.current.strftime("%Y%m%d")
  end

  def school_in_local_authority_scope?(row)
    school_is_local_authority_maintained?(row) || school_is_community_or_foundation_special_school?(row)
  end

  def school_is_local_authority_maintained?(row)
    row["EstablishmentTypeGroup (code)"] == "4"
  end

  def school_is_community_or_foundation_special_school?(row)
    row["EstablishmentTypeGroup (code)"] == "5" && %w[7 12].include?(row["TypeOfEstablishment (code)"])
  end

  def set_readable_phases(school)
    school.readable_phases = READABLE_PHASE_MAPPINGS[school.phase.to_sym]
  end

  def simple_mappings
    {
      address: "Street",
      detailed_school_type: "TypeOfEstablishment (name)",
      easting: "Easting",
      establishment_status: "EstablishmentStatus (name)",
      local_authority_within: "LA (name)",
      maximum_age: "StatutoryHighAge",
      minimum_age: "StatutoryLowAge",
      name: "EstablishmentName",
      northing: "Northing",
      postcode: "Postcode",
      region: "GOR (name)",
      school_type: "EstablishmentTypeGroup (name)",
      town: "Town",
    }.freeze
  end
end
