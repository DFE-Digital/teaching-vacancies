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
          vacancy: {
            type: :object,
            additionalProperties: false,
            required: %i[id
                         external_advert_url
                         expires_at
                         starts_on
                         job_title
                         skills_and_experience
                         salary
                         external_reference
                         job_roles
                         working_patterns
                         contract_type
                         phases
                         publish_on
                         schools],
            properties: {
              id: { type: :string, example: "9d8f5715-2e7c-4e64-8e34-35f510c12e66" },
              external_advert_url: { type: :string, example: "https://example.com/jobs/123" },
              publish_on: { type: :string, format: :date },
              expires_at: { type: :string, format: :date },
              job_title: { type: :string, example: "Teacher of Geography" },
              skills_and_experience: { type: :string, example: "We're looking for a dedicated Teacher of Geography" },
              salary: { type: :string, example: "£12,345 to £67, 890" },
              benefits_details: { type: :string, example: "TLR2a" },
              starts_on: { type: :string, example: "Summer Term" },
              external_reference: { type: :string, example: "123GTZY" },
              visa_sponsorship_available: { type: :boolean },
              is_job_share: { type: :boolean },
              schools: {
                oneOf: [
                  {
                    type: :object,
                    additionalProperties: false,
                    required: %i[school_urns],
                    properties: {
                      school_urns: {
                        type: :array,
                        minItems: 1,
                        items: {
                          type: :string,
                          example: "12345",
                        },
                      },
                    },
                  },
                  {
                    type: :object,
                    additionalProperties: false,
                    required: %i[trust_uid school_urns],
                    properties: {
                      trust_uid: {
                        type: :string,
                        example: "12345",
                      },
                      school_urns: {
                        type: :array,
                        minItems: 0,
                        items: {
                          type: :string,
                          example: "12345",
                        },
                      },
                    },
                  },
                  {
                    type: :object,
                    additionalProperties: false,
                    required: %i[trust_uid],
                    properties: {
                      trust_uid: {
                        type: :string,
                        example: "12345",
                      },
                    },
                  },
                ],
              },
              job_roles: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.job_roles.keys,
                },
              },
              ect_suitable: {
                type: :boolean,
              },
              working_patterns: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.working_patterns.keys,
                },
              },
              contract_type: {
                type: :string,
                enum: Vacancy.contract_types.keys,
              },
              phases: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.phases.keys,
                },
              },
              key_stages: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.key_stages.keys,
                },
              },
              subjects: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: ["Accounting",
                         "Art and design",
                         "Biology",
                         "Business Studies",
                         "Chemistry",
                         "Citizenship",
                         "Classics",
                         "Computing",
                         "Dance",
                         "Design And Technology",
                         "Drama",
                         "Economics",
                         "Engineering",
                         "English",
                         "Food Technology",
                         "French",
                         "Geography",
                         "German",
                         "health_and_social_care",
                         "history",
                         "Humanities",
                         "ICT",
                         "Languages",
                         "Law",
                         "Mandarin",
                         "Mathematics",
                         "Media Studies",
                         "Music",
                         "Philosophy",
                         "Physical Education",
                         "Physics",
                         "PSHE",
                         "Psychology",
                         "Religious Education",
                         "Science",
                         "Social Science",
                         "Sociology",
                         "Spanish",
                         "Statistics"],
                },
              },
            },
          },
          create_vacancy_response: {
            type: :object,
            properties: {
              id: { type: :string, example: "9d8f5715-2e7c-4e64-8e34-35f510c12e66" },
              errors: {
                type: :array,
                items: { type: :string },
                nullable: true,
              },
            },
            required: %w[id],
          },
          bad_request_error: {
            type: "object",
            properties: {
              error: { type: "string", example: "Request body could not be read properly" },
            },
            required: %w[error],
          },
          unauthorized_error: {
            type: "object",
            properties: {
              error: { type: "string", example: "Invalid API key" },
            },
            required: %w[error],
          },
          not_found_error: {
            type: "object",
            properties: {
              error: { type: "string", example: "The given ID does not match any vacancy for your ATS" },
            },
            required: %w[error],
          },
          internal_server_error: {
            type: "object",
            properties: {
              error: { type: "string", example: "There was an internal error processing this request" },
            },
            required: %w[error],
          },
          conflict_error: {
            type: "object",
            properties: {
              error: { type: "string", example: "A vacancy with the provided external reference already exists" },
            },
            required: %w[error],
          },
          validation_error: {
            type: "object",
            properties: {
              errors: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    error: { type: "string", example: "job_title: can't be blank" },
                  },
                  required: %w[error],
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
  # config.openapi_no_additional_properties = false # Allow additional properties
end
