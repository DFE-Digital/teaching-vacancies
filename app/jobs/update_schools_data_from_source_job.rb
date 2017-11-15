require 'csv'
require 'open-uri'

class UpdateSchoolsDataFromSourceJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/AbcSize
  def perform
    datestring = Time.zone.now.strftime('%Y%m%d')
    url = "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv"

    file = open(url).read

    # Convert from Windows-1251 encoding to UTF-8
    file.encode!('UTF-8', 'windows-1251', invalid: :replace)

    CSV.parse(file, headers: true).each do |row|
      school_type = SchoolType.find_or_initialize_by(code: row['EstablishmentTypeGroup (code)'])
      school_type.label ||= row['EstablishmentTypeGroup (name)']
      school_type.save!

      detailed_school_type = DetailedSchoolType.find_or_initialize_by(code: row['TypeOfEstablishment (code)'])
      detailed_school_type.label ||= row['TypeOfEstablishment (name)']
      detailed_school_type.save!

      region = Region.find_or_initialize_by(code: row['GOR (code)'])
      region.name ||= row['GOR (name)']
      region.save!

      school = School.find_or_initialize_by(urn: row['URN'])
      school.name = row['EstablishmentName']
      school.address = row['Street']
      school.locality = row['Locality'].presence
      school.address3 = row['Address3'].presence
      school.town = row['Town']
      school.county = row['County (name)'].presence
      school.postcode = row['Postcode']
      school.minimum_age = row['StatutoryLowAge']
      school.maximum_age = row['StatutoryHighAge']

      school.easting = row['Easting']
      school.northing = row['Northing']

      website = row['SchoolWebsite']
      website = "http://#{website}" unless website.start_with? 'http'

      school.url = website.presence

      school.phase = row['PhaseOfEducation (code)'].to_i

      school.school_type = school_type
      school.detailed_school_type = detailed_school_type
      school.region = region
      school.save!
    end
    # rubocop:enable Metrics/AbcSize
  end
end
