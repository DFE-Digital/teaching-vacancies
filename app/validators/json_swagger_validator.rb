# frozen_string_literal: true

require "json-schema"

# Uses the swagger file to load the JSON schema for an API endpoint,
# thus helping to enforce input schema validation on API clients
class JsonSwaggerValidator
  def initialize(path, key)
    @schema = load_schema(path, key)
  end

  def valid?(payload)
    JSON::Validator.validate(@schema, payload)
  end

  def errors(payload)
    JSON::Validator.fully_validate(@schema, payload)
  end

  private

  def load_schema(path, key)
    yaml = YAML.load_file(Rails.root.join("swagger/v1/swagger.yaml"))
    component_ref = yaml.dig("paths", path, key, "requestBody", "content", "application/json", "schema", "$ref").split("/").last
    yaml.dig("components", "schemas", component_ref)
  end
end
