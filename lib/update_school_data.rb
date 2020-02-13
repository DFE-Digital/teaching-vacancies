require 'csv'
require 'open-uri'
require 'httparty'

class UpdateSchoolData
  def run
    save_csv_file
    CSV.foreach(csv_file_location, headers: true, encoding: 'windows-1251:utf-8').each do |row|
      School.transaction do
        next if row['EstablishmentStatus (name)'].eql?('Closed')

        school = convert_to_school(row)
        school.save
      end
    end

    File.delete(csv_file_location)
  end

  private

  def convert_to_school(row)
    school = School.find_or_initialize_by(urn: row['URN'])

    set_properties(school, row)
    set_region(school, row)
    set_school_type(school, row)

    school
  end

  # rubocop:disable Metrics/AbcSize
  def set_properties(school, row)
    school.name = row['EstablishmentName']
    school.address = row['Street']
    school.locality = row['Locality'].presence
    school.address3 = row['Address3'].presence
    school.town = row['Town']
    school.county = row['County (name)'].presence
    school.postcode = row['Postcode']
    school.local_authority = row['LA (name)']
    school.minimum_age = row['StatutoryLowAge']
    school.maximum_age = row['StatutoryHighAge']
    school.easting = row['Easting']
    school.northing = row['Northing']
    school.url = valid_website(row['SchoolWebsite'])
    school.phase = row['PhaseOfEducation (code)'].to_i
    school.status = row['EstablishmentStatus (name)']
    school.trust_name = row['Trusts (name)']
    school.number_of_pupils = row['NumberOfPupils']
    school.head_title = row['HeadTitle (name)']
    school.head_first_name = row['HeadFirstName']
    school.head_last_name = row['HeadLastName']
    school.religious_character = row['ReligiousCharacter (name)']
    school.rsc_region = row['RSCRegion (name)']
    school.telephone = row['TelephoneNum']
    school.open_date = row['OpenDate']
    school.close_date = row['CloseDate']
    school.last_ofsted_inspection_date = row['OfstedLastInsp']
    school.oftsed_rating = row['OfstedRating (name)']
  end
  # rubocop:enable Metrics/AbcSize

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

  def valid_website(url)
    Addressable::URI.heuristic_parse(url).to_s
  end
end
