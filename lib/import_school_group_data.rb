require 'csv'
require 'httparty'

CSV_URL = 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata.csv'
TEMP_CSV_FILE_LOCATION = './tmp/school-groups-data.csv'

class ImportSchoolGroupData
  def run!
    save_csv_file
    CSV.foreach(TEMP_CSV_FILE_LOCATION, headers: true, encoding: 'windows-1251:utf-8').each do |row|
      SchoolGroup.transaction do
        school_group = convert_to_school_group(row)
        school_group.save
      end
    end

    File.delete(TEMP_CSV_FILE_LOCATION)
  end

  private

  def convert_to_school_group(row)
    school_group = SchoolGroup.find_or_initialize_by(uid: row['Group UID'])
    set_gias_data_as_json(school_group, row)

    school_group
  end

  def set_gias_data_as_json(school_group, row)
    gias_hash = {}
    row.each { |element| gias_hash[element.first] = element.last }
    # The gias_data column is type `json`. It automatically converts the ruby hash to json.
    school_group.gias_data = gias_hash
  end

  def save_csv_file(url = CSV_URL, location = TEMP_CSV_FILE_LOCATION)
    request = HTTParty.get(url)

    if request.code == 200
      File.write(location, request.body, mode: 'wb')
    elsif request.code == 404
      raise HTTParty::ResponseError, 'SchoolGroup CSV file not found.'
    else
      raise HTTParty::ResponseError, 'Unexpected problem downloading SchoolGroup CSV file.'
    end
  end
end
