require 'csv'
require 'open-uri'
require 'httparty'

class UpdateSchoolData
  # TODO: Refactor the transformation logic into the model.
  # These are the attributes that require additional transformation before being added to the model. The first value of
  # the array is the row key name, the second is the method used for the transformation.  URL is the exception, as it
  # requires an external function call-this is handled in the method.
  #
  COMPLEX_MAPPINGS = {
    address3: ['Address3', :presence],
    county: ['County (name)', :presence],
    locality: ['Locality', :presence],
    phase: ['PhaseOfEducation (code)', :to_i],
    url: ['SchoolWebsite', nil],
  }.freeze

  SIMPLE_MAPPINGS = {
    address: 'Street',
    easting: 'Easting',
    local_authority: 'LA (name)',
    maximum_age: 'StatutoryHighAge',
    minimum_age: 'StatutoryLowAge',
    name: 'EstablishmentName',
    northing: 'Northing',
    postcode: 'Postcode',
    town: 'Town',
  }.freeze

  READABLE_PHASE_MAPPINGS = School::READABLE_PHASE_MAPPINGS

  def run!
    save_csv_file
    CSV.foreach(csv_file_location, headers: true, encoding: 'windows-1252:utf-8').each do |row|
      School.transaction do
        school = convert_to_school(row)
        school.save
      end
    end

    File.delete(csv_file_location)
  end

private

  def convert_to_school(row)
    school = School.find_or_initialize_by(urn: row['URN'])

    set_complex_properties(school, row)
    set_simple_properties(school, row)
    set_region(school, row)
    set_school_type(school, row)
    set_gias_data_as_json(school, row)
    set_readable_phases(school)

    school
  end

  def set_readable_phases(school)
    school.readable_phases = READABLE_PHASE_MAPPINGS[school.phase.to_sym]
  end

  def set_complex_properties(school, row)
    COMPLEX_MAPPINGS.each do |attribute_name, value|
      row_key = value.first
      transformation = value.last
      school[attribute_name] = if attribute_name == :url
        # Addressable::URI ensures we store a valid URL.
        Addressable::URI.heuristic_parse(row[row_key]).to_s
                               else
        row[row_key].send(transformation)
                               end
    end
  end

  def set_simple_properties(school, row)
    SIMPLE_MAPPINGS.each do |attribute_name, column_name|
      # Using `send` for this  because `easting` and `northing` are both overloaded setters that look up lat/long when
      # you set them.
      school.send("#{attribute_name}=", row[column_name])
    end
  end

  def set_gias_data_as_json(school, row)
    scratch = {}
    row.each { |element| scratch[element.first] = element.last }
    # The gias_data column is type `json`. It automatically converts the ruby hash to json.
    school.gias_data = scratch
  end

  def set_region(school, row)
    region = Region.find_or_initialize_by(code: row['GOR (code)'])
    region.name = row['GOR (name)']
    school.region = region
  end

  def set_school_type(school, row)
    school_type = SchoolType.find_or_initialize_by(code: row['EstablishmentTypeGroup (code)'])
    school_type.label = row['EstablishmentTypeGroup (name)']
    detailed_school_type = DetailedSchoolType.find_or_initialize_by(code: row['TypeOfEstablishment (code)'])
    detailed_school_type.label = row['TypeOfEstablishment (name)']
    school.school_type = school_type
    school.detailed_school_type = detailed_school_type
  end

  def datestring
    Time.zone.now.strftime('%Y%m%d')
  end

  def csv_file_location
    "./tmp/#{datestring}-schools-data.csv"
  end

  def save_csv_file(location: csv_file_location)
    File.open(location, 'wb') do |f|
      request = HTTParty.get(csv_url)

      if request.code == 200
        f.write request.body
      elsif request.code == 404
        raise HTTParty::ResponseError, 'School CSV file not found.'
      else
        raise HTTParty::ResponseError, 'Unexpected problem downloading School CSV file.'
      end
    end
  end

  def csv_url
    "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv"
  end
end
