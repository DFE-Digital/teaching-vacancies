require 'csv'
require 'geocoding'
require 'httparty'

SCHOOL_GROUP_URL = 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata.csv'.freeze
SCHOOL_GROUP_TEMP_LOCATION = './tmp/school-group-data.csv'.freeze

SCHOOL_GROUP_MEMBERSHIP_URL = 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/alllinksdata.csv'.freeze
SCHOOL_GROUP_MEMBERSHIP_TEMP_LOCATION = './tmp/school-group-membership-data.csv'.freeze

class ImportSchoolGroupData
  def run!
    import_data(SCHOOL_GROUP_URL, SCHOOL_GROUP_TEMP_LOCATION, :create_school_groups)
    import_data(SCHOOL_GROUP_MEMBERSHIP_URL, SCHOOL_GROUP_MEMBERSHIP_TEMP_LOCATION, :create_school_group_memberships)
  end

private

  def import_data(url, location, method)
    save_csv_file(url, location)
    CSV.foreach(location, headers: true, encoding: 'windows-1252:utf-8').each do |row|
      send(method, row)
    end
    File.delete(location)
  end

  def create_school_groups(row)
    # Only import MAT data
    if row['Group Type (code)'] == '06'
      SchoolGroup.transaction do
        school_group = convert_to_school_group(row)
        school_group.save
      end
    end
  end

  def create_school_group_memberships(row)
    SchoolGroupMembership.transaction do
      school_group = SchoolGroup.find_by(uid: row['Group UID'])
      school = School.find_by(urn: row['URN'])

      SchoolGroupMembership.find_or_create_by(school_id: school.id, school_group_id: school_group.id) if
        school.present? && school_group.present?
    end
  end

  def save_csv_file(url, location)
    request = HTTParty.get(url)
    if request.code == 200
      File.write(location, request.body, mode: 'wb')
    elsif request.code == 404
      raise HTTParty::ResponseError, 'CSV file not found.'
    else
      raise HTTParty::ResponseError, 'Unexpected problem downloading CSV file.'
    end
  end

  def convert_to_school_group(row)
    school_group = SchoolGroup.find_or_initialize_by(uid: row['Group UID'])
    set_gias_data_as_json(school_group, row)
    school_group.postcode = row['Group Postcode']
    school_group.name = row['Group Name']&.titlecase
    school_group.address = row['Group Locality']
    school_group.town = row['Group Town']
    school_group.county = row['Group County']
    set_geolocation(school_group)
    school_group
  end

  def set_geolocation(school_group)
    coordinates = Geocoding.new(school_group.postcode).coordinates
    school_group.geolocation = coordinates unless coordinates == [0, 0]
  end

  def set_gias_data_as_json(school_group, row)
    gias_hash = {}
    row.each { |element| gias_hash[element.first] = element.last }
    # The gias_data column is type `json`. It automatically converts the ruby hash to json.
    school_group.gias_data = gias_hash
  end
end
