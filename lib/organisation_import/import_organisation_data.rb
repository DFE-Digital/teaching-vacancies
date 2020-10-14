require 'csv'
require 'geocoding'
require 'httparty'
require 'open-uri'

class ImportOrganisationData
# NB: To me it doesn't seem too unreasonable to have the transformation logic here, but in the interest of not
#     deleting comments I didn't write, see the TODO below.
# TODO: Refactor the transformation logic into the model.
# These are the attributes that require additional transformation before being added to the model. The first value of
# the array is the row key name, the second is the method used for the transformation.  URL is the exception, as it
# requires an external function call-this is handled in the method.

private

  def create_organisation(row)
    organisation = convert_to_organisation(row)
    organisation.save
    organisation
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

  def set_complex_properties(organisation, row)
    complex_mappings.each do |attribute_name, value|
      row_key = value.first
      transformation = value.last
      organisation[attribute_name] = if attribute_name == :url
        # Addressable::URI ensures we store a valid URL.
        Addressable::URI.heuristic_parse(row[row_key]).to_s
                                     else
        row[row_key].send(transformation)
                                     end
    end
  end

  def set_gias_data_as_json(organisation, row)
    gias_hash = {}
    row.each { |element| gias_hash[element.first] = element.last }
    # The gias_data column is type `json`. It automatically converts the ruby hash to json.
    organisation.gias_data = gias_hash
  end

  def set_simple_properties(organisation, row)
    simple_mappings.each do |attribute_name, column_name|
      # Using `send` for this  because `easting` and `northing` are both overloaded setters that look up lat/long when
      # you set them.
      organisation.send("#{attribute_name}=", row[column_name])
    end
  end
end
