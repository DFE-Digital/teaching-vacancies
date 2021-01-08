require "csv"
require "geocoding"
require "httparty"
require "open-uri"

class ImportOrganisationData
private

  def create_organisation(row)
    organisation = convert_to_organisation(row)
    organisation.save
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
end
