require 'csv'
require 'open-uri'
require 'httparty'

class UpdateSchoolsDataFromSourceJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/AbcSize
  def perform
    save_csv_file

    CSV.foreach(csv_file_location, headers: true, encoding: 'windows-1251:utf-8').each do |row|
      School.transaction do
        next if row['EstablishmentStatus (name)'].eql?('Closed')

        school_type = SchoolType.find_or_initialize_by(code: row['EstablishmentTypeGroup (code)'])
        school_type.label = row['EstablishmentTypeGroup (name)']

        detailed_school_type = DetailedSchoolType.find_or_initialize_by(code: row['TypeOfEstablishment (code)'])
        detailed_school_type.label = row['TypeOfEstablishment (name)']

        region = Region.find_or_initialize_by(code: row['GOR (code)'])
        region.name = row['GOR (name)']

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

        school.url = valid_website(row['SchoolWebsite'])

        school.phase = row['PhaseOfEducation (code)'].to_i

        school.school_type = school_type
        school.detailed_school_type = detailed_school_type
        school.region = region

        local_authority = LocalAuthority.find_by(code: row['LA (code)'])
        school.local_authority = local_authority
        school.regional_pay_band_area ||= local_authority.default_regional_pay_band_area

        school.save
      end
    end
    # rubocop:enable Metrics/AbcSize

    File.delete(csv_file_location)
  end

  private

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
    "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv"
  end

  def valid_website(url)
    Addressable::URI.heuristic_parse(url).to_s
  end
end
