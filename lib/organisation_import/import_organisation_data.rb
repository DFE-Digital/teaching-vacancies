require "csv"
require "geocoding"
require "httparty"
require "open-uri"

class ImportOrganisationData
  def run!
    csv_metadata.each { |metadata| import_data(metadata) }
  end

  def self.mark_all_school_group_memberships_to_be_deleted!
    SchoolGroupMembership.update_all(do_not_delete: false)
  end

  def self.delete_marked_school_group_memberships!
    memberships_to_delete = SchoolGroupMembership.where(do_not_delete: false)
    raise SuspiciouslyHighNumberOfRecordsToDelete, memberships_to_delete.count if memberships_to_delete.count > 10

    memberships_to_delete.delete_all
  end

  private

  class SuspiciouslyHighNumberOfRecordsToDelete < StandardError
    def initialize(count)
      @count = count
    end

    def message
      "There was a suspiciously high number of SchoolGroupMemberships to delete: #{@count}. Skipped deletion."
    end
  end

  def import_data(csv_url:, csv_file_location:, method:)
    save_csv_file(csv_url, csv_file_location)
    CSV.foreach(csv_file_location, headers: true, encoding: "windows-1252:utf-8").each do |row|
      Organisation.transaction do
        send(method, row)
      end
    end
    File.delete(csv_file_location)
  end

  def create_organisation(row)
    organisation = convert_to_organisation(row)
    organisation&.save
    organisation
  end

  def save_csv_file(url, location)
    request = HTTParty.get(url)
    case request.code
    when 200
      File.write(location, request.body, mode: "wb")
    when 404
      raise HTTParty::ResponseError, "CSV file not found."
    else
      raise HTTParty::ResponseError, "Unexpected problem downloading CSV file."
    end
  end

  def set_gias_data_as_json(organisation, row)
    gias_hash = {}
    row.each { |element| gias_hash[element.first] = element.last }
    # The gias_data column is type `json`. It automatically converts the ruby hash to json.
    organisation.gias_data = gias_hash
  end

  def set_properties(organisation, row)
    column_name_mappings.each do |attribute_name, column_name|
      transformation = column_value_transformations[attribute_name]
      value = if transformation
                transformation.to_proc.call(row[column_name])
              else
                row[column_name]
              end

      # Using `send` for this  because `easting` and `northing` are both overloaded setters that look up lat/long when
      # you set them.
      organisation.send("#{attribute_name}=", value.presence)
    end
  end

  def datestring
    Time.current.strftime("%Y%m%d")
  end
end
