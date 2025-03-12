require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Teaching Vacancies ATS API",
        version: "v1",
        description: <<~DESCRIPTION,
          This document outlines the API’s key features, the data required for each listing,
          and the steps needed to set up an integration.

          This documentation describes each endpoint’s request parameters, response formats, and possible errors,
          so you can seamlessly integrate Teaching Vacancies into your ATS workflow.

          ## Introduction

          <img src="/teaching_vacancies_api_diagram.jpg" alt="diagram" width="960" height="540">

          The **Teaching Vacancies ATS API** enables you to manage job listings on behalf of schools or trusts
          through your own Applicant Tracking System (ATS) or HR software.

          By calling this API, you can:

          - **List** all your active vacancies (with pagination)
          - **Retrieve** details for a single vacancy
          - **Create** new vacancies
          - **Update** existing vacancies
          - **Delete** vacancies if they need to be removed before their expiration date

          ## Authentication

          Each request requires a valid API key in the `X-Api-Key` header to ensure only authorised
          clients can manage vacancies.

          Include this key in the `X-Api-Key` header of each request.
          If the key is missing or invalid, the API will respond with an `HTTP 401` (Unauthorized) status.

          This ensures that only approved clients can create, update, or remove job listings.
          If you ever need a new or replacement key, let us know, and we’ll assist you with the process.
          You can reach us at [teachingvacancies.ats@education.gov.uk](mailto:teachingvacancies.ats@education.gov.uk).

          **Base URL**: `/ats-api/v1`

          **Supported Formats**: JSON

          **Authentication**: API key in `X-Api-Key`

        DESCRIPTION
      },
      paths: {},
      components: {
        securitySchemes: {
          api_key: {
            type: :apiKey,
            name: "X-Api-Key",
            in: :header,
          },
        },
        schemas: {
          vacancy_request: {
            type: :object,
            additionalProperties: false,
            required: %i[external_advert_url
                         expires_at
                         job_title
                         job_advert
                         salary
                         external_reference
                         job_roles
                         working_patterns
                         contract_type
                         phases
                         schools],
            properties: {
              external_advert_url: {
                type: :string,
                format: :uri,
                example: "https://example.com/jobs/123",
                description: "The URL where the job is advertised externally.",
              },
              publish_on: {
                type: :string,
                format: :date,
                example: "2025-01-01",
                description: "The date on which the vacancy should be published. Defaults to the current date.",
              },
              expires_at: {
                type: :string,
                format: :datetime,
                example: "2025-03-13T15:30:00Z",
                description: "The end datetime of the vacancy. Must be after the start date.",
              },
              job_title: {
                type: :string,
                example: "Teacher of Geography",
                description: "The short job title shown in the page title and search results.",
              },
              job_advert: {
                type: :string,
                example: "We're looking for a dedicated Teacher of Geography to join our team. The ideal candidate will have a passion for teaching and a deep understanding of the subject matter. Responsibilities include preparing lesson plans, delivering engaging lessons, and assessing student progress.",
                description: "The long form job advert text shown on the job listing.",
              },
              salary: {
                type: :string,
                example: "£12,345 to £67,890",
                description: "Compensation for the role.",
              },
              benefits_details: {
                type: :string,
                example: "TLR2a",
                description: "Any additional benefits or allowances.",
              },
              starts_on: {
                type: :string,
                example: "Easter",
                description: "The start date (or approximate start timeframe) of the job.",
              },
              external_reference: {
                type: :string,
                example: "123GTZY",
                description: "An external reference or identifier for your own tracking.",
              },
              visa_sponsorship_available: {
                type: :boolean,
                example: false,
                description: "Indicates if a visa sponsorship is available for this role. Defaults to false.",
              },
              is_job_share: {
                type: :boolean,
                example: true,
                description: "Whether the role is open to a job share. Defaults to false.",
              },
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
                          example: "123456",
                          description: "The unique reference number (URN) for an individual school.",
                        },
                      },
                    },
                    description: "Schema for a vacancy belonging to one or more schools by URN.",
                  },
                  {
                    type: :object,
                    additionalProperties: false,
                    required: %i[trust_uid school_urns],
                    properties: {
                      trust_uid: {
                        type: :string,
                        example: "12345",
                        description: "Unique identifier for a trust.",
                      },
                      school_urns: {
                        type: :array,
                        minItems: 0,
                        items: {
                          type: :string,
                          example: "12345",
                          description: "URNs of individual schools under the trust (optional).",
                        },
                      },
                    },
                    description: "Schema for a vacancy belonging to a trust, possibly linked to multiple schools.",
                  },
                  {
                    type: :object,
                    additionalProperties: false,
                    required: %i[trust_uid],
                    properties: {
                      trust_uid: {
                        type: :string,
                        example: "12345",
                        description: "Unique identifier for a trust.",
                      },
                    },
                    description: "Schema for a vacancy belonging to a trust without any specific school URNs.",
                  },
                ],
                description: "Specifies which school(s) or trust the vacancy belongs to.",
              },
              job_roles: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.job_roles.keys,
                  description: "Valid job role, e.g. 'teacher', 'senior_leader', etc.",
                },
                description: "An array of one or more job roles associated with the vacancy.",
              },
              ect_suitable: {
                type: :boolean,
                example: true,
                description: "Indicates whether the vacancy is suitable for ECTs (Early Career Teachers).",
              },
              working_patterns: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy::WORKING_PATTERNS,
                  description: "Valid working pattern, e.g. 'full_time', 'part_time', etc.",
                },
                description: "An array of one or more working patterns for the vacancy.",
              },
              contract_type: {
                type: :string,
                enum: Vacancy.contract_types.keys,
                example: "permanent",
                description: "The type of contract, e.g. 'permanent', 'fixed_term'.",
              },
              phases: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.phases.keys,
                  description: "Valid phase, e.g. 'primary', 'secondary', etc.",
                },
                description: "One or more phases of education that the vacancy covers.",
              },
              key_stages: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.key_stages.keys,
                  description: "Valid key stage, e.g. 'ks1', 'ks2', etc.",
                },
                description: "One or more key stages relevant to the vacancy.",
              },
              subjects: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: [
                    "Accounting",
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
                    "Statistics",
                  ],
                  description: "Valid subject for the job, e.g. 'Biology', 'English', etc.",
                },
                description: "An array of subjects relevant to the vacancy.",
              },
            },
          },
          vacancy_response: {
            type: :object,
            additionalProperties: false,
            # A schema shouldn't need to define required properties if it's a response
            # However Rswag tests will only check for the response properties presence if they're defined as required.
            required: %i[id
                         job_title
                         external_reference
                         external_advert_url
                         expires_at
                         job_advert
                         salary
                         schools
                         job_roles
                         working_patterns
                         contract_type
                         phases],
            properties: {
              id: {
                type: :string,
                format: :uuid,
                example: "9d8f5715-2e7c-4e64-8e34-35f510c12e66",
                description: "The unique identifier for the vacancy.",
              },
              external_advert_url: {
                type: :string,
                format: :uri,
                example: "https://example.com/jobs/123",
                description: "The URL where the job is advertised externally.",
              },
              publish_on: {
                type: :string,
                format: :date,
                example: "2025-01-01",
                description: "The date on which the vacancy should be published.Defaults to the current date.",
              },
              expires_at: {
                type: :string,
                format: :datetime,
                example: "2025-03-13T15:30:00Z",
                description: "The end datetime of the vacancy. Must be after the start date.",
              },
              job_title: {
                type: :string,
                example: "Teacher of Geography",
                description: "The short job title shown in the page title and search results.",
              },
              job_advert: {
                type: :string,
                example: "We're looking for a dedicated Teacher of Geography to join our team. The ideal candidate will have a passion for teaching and a deep understanding of the subject matter. Responsibilities include preparing lesson plans, delivering engaging lessons, and assessing student progress.",
                description: "The long form job advert text shown on the job listing.",
              },
              salary: {
                type: :string,
                example: "£12,345 to £67,890",
                description: "Compensation for the role.",
              },
              benefits_details: {
                type: :string,
                example: "TLR2a",
                description: "Any additional benefits or allowances.",
              },
              starts_on: {
                type: :string,
                example: "Easter",
                description: "The start date (or approximate start timeframe) of the job.",
              },
              external_reference: {
                type: :string,
                example: "123GTZY",
                description: "An external reference or identifier for your own tracking.",
              },
              visa_sponsorship_available: {
                type: :boolean,
                example: false,
                description: "Indicates if a visa sponsorship is available for this role. Defaults to false.",
              },
              is_job_share: {
                type: :boolean,
                example: true,
                description: "Whether the role is open to a job share. Defaults to false.",
              },
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
                          example: "123456",
                          description: "The unique reference number (URN) for an individual school.",
                        },
                      },
                    },
                    description: "Schema for a vacancy belonging to one or more schools by URN.",
                  },
                  {
                    type: :object,
                    additionalProperties: false,
                    required: %i[trust_uid school_urns],
                    properties: {
                      trust_uid: {
                        type: :string,
                        example: "12345",
                        description: "Unique identifier for a trust.",
                      },
                      school_urns: {
                        type: :array,
                        minItems: 0,
                        items: {
                          type: :string,
                          example: "12345",
                          description: "URNs of individual schools under the trust (optional).",
                        },
                      },
                    },
                    description: "Schema for a vacancy belonging to a trust, possibly linked to multiple schools.",
                  },
                  {
                    type: :object,
                    additionalProperties: false,
                    required: %i[trust_uid],
                    properties: {
                      trust_uid: {
                        type: :string,
                        example: "12345",
                        description: "Unique identifier for a trust.",
                      },
                    },
                    description: "Schema for a vacancy belonging to a trust without any specific school URNs.",
                  },
                ],
                description: "Specifies which school(s) or trust the vacancy belongs to.",
              },
              job_roles: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.job_roles.keys,
                  description: "Valid job role, e.g. 'teacher', 'senior_leader', etc.",
                },
                description: "An array of one or more job roles associated with the vacancy.",
              },
              ect_suitable: {
                type: :boolean,
                example: true,
                description: "Indicates whether the vacancy is suitable for ECTs (Early Career Teachers). Defaults to false.",
              },
              working_patterns: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy::WORKING_PATTERNS,
                  description: "Valid working pattern, e.g. 'full_time', 'part_time', etc.",
                },
                description: "An array of one or more working patterns for the vacancy.",
              },
              contract_type: {
                type: :string,
                enum: Vacancy.contract_types.keys,
                example: "permanent",
                description: "The type of contract, e.g. 'permanent', 'fixed_term'.",
              },
              phases: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.phases.keys,
                  description: "Valid phase, e.g. 'primary', 'secondary', etc.",
                },
                description: "One or more phases of education that the vacancy covers.",
              },
              key_stages: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: Vacancy.key_stages.keys,
                  description: "Valid key stage, e.g. 'ks1', 'ks2', etc.",
                },
                description: "One or more key stages relevant to the vacancy.",
              },
              subjects: {
                type: :array,
                minItems: 1,
                items: {
                  type: :string,
                  enum: [
                    "Accounting",
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
                    "Statistics",
                  ],
                  description: "Valid subject for the job, e.g. 'Biology', 'English', etc.",
                },
                description: "An array of subjects relevant to the vacancy.",
              },
            },
          },
          vacancies_response: {
            type: :object,
            additionalProperties: false,
            required: %i[data meta], # Required so Rswag tests assert their presence in the API responses
            properties: {
              data: {
                type: :array,
                items: {
                  "$ref" => "#/components/schemas/vacancy_response",
                },
              },
              meta: {
                type: :object,
                additionalProperties: false,
                properties: {
                  totalPages: {
                    type: :integer,
                  },
                  count: {
                    type: :integer,
                  },
                },
              },
            },
          },

          create_vacancy_response: {
            type: :object,
            required: %i[id], # Required so Rswag tests assert its presence in the API responses
            properties: {
              id: {
                type: :string,
                format: :uuid,
                example: "9d8f5715-2e7c-4e64-8e34-35f510c12e66",
                description: "The unique identifier of the vacancy that was just created.",
              },
            },
          },
          bad_request_error: {
            type: :object,
            required: %w[error], # Required so Rswag tests assert its presence in the API responses
            properties: {
              error: {
                type: :string,
                example: "Request body could not be read properly",
                description: "A description of the bad request error.",
              },
            },
          },
          unauthorized_error: {
            type: :object,
            required: %w[error], # Required so Rswag tests assert its presence in the API responses
            properties: {
              error: {
                type: :string,
                example: "Invalid API key",
                description: "A description of the unauthorised error.",
              },
            },
          },
          not_found_error: {
            type: :object,
            required: %w[error], # Required so Rswag tests assert its presence in the API responses
            properties: {
              error: {
                type: :string,
                example: "The given ID does not match any vacancy for your ATS",
                description: "A description of the resource not found error.",
              },
            },
          },
          internal_server_error: {
            type: :object,
            required: %w[error], # Required so Rswag tests assert its presence in the API responses
            properties: {
              error: {
                type: :string,
                example: "There was an internal error processing this request",
                description: "A description of the internal server error.",
              },
            },
          },
          conflict_error: {
            type: :object,
            required: %w[error], # Required so Rswag tests assert its presence in the API responses
            properties: {
              error: {
                type: :string,
                example: "A vacancy with the provided external reference already exists",
                description: "A description of the conflict error.",
              },
              link: {
                type: :string,
                format: :uri,
                example: "https://example.com/vacancies/123",
                description: "A link to the existing conflicting resource (if applicable).",
              },
            },
          },
          validation_error: {
            type: :object,
            required: %w[errors], # Required so Rswag tests assert its presence in the API responses
            properties: {
              errors: {
                type: :array,
                items: {
                  type: :string,
                  example: "job_title: can't be blank",
                  description: "A message describing a specific validation error.",
                },
                description: "An array of validation errors.",
              },
            },
          },
        },
      },
    },
  }

  config.openapi_format = :yaml
end
