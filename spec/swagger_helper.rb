require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Teaching Vacancies ATS API",
        version: "v1",
      },
      paths: {},
      # servers: [
      #   {
      #     url: "https://{defaultHost}",
      #     variables: {
      #       defaultHost: {
      #         default: "localhost:3000",
      #       },
      #     },
      #   },
      # ],
      components: {
        securitySchemes: {
          api_key: {
            type: :apiKey,
            name: "X-Api-Key",
            in: :header,
          },
        },
        schemas: {
          unauthorized_error: {
            type: "object",
            properties: {
              errors: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    error: { type: "string", example: "unauthorized" },
                    message: { type: "string", example: "Invalid API key" },
                  },
                  required: %w[error message],
                },
              },
            },
          },
          not_found_error: {
            type: "object",
            properties: {
              errors: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    error: { type: "string", example: "not found" },
                    message: { type: "string", example: "The vacancy ID does not match any vacancy for your ATS" },
                  },
                  required: %w[error message],
                },
              },
            },
          },
          internal_server_error: {
            type: "object",
            properties: {
              errors: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    error: { type: "string", example: "internal server error" },
                    message: { type: "string", example: "There was an internal error processing this request" },
                  },
                  required: %w[error message],
                },
              },
            },
          },
          validation_error: {
            type: "object",
            properties: {
              errors: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    error: { type: "string", example: "validation error" },
                    field: { type: "string", example: "job_title" },
                    message: { type: "string", example: "can't be blank" },
                  },
                  required: %w[error field message],
                },
              },
            },
          },
        },
      },
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
