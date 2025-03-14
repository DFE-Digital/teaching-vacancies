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
            required: [:vacancy],
            additionalProperties: false,
            properties: {
              vacancy: {
                additionalProperties: false,
                description: "The vacancy details to create or update.",
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
                  external_advert_url: {
                    type: :string,
                    format: :uri,
                    example: "https://example.com/jobs/123",
                    description: "The URL where the job is advertised externally.",
                  },
                  external_reference: {
                    type: :string,
                    example: "123GTZY",
                    description: "An external reference or identifier for your own tracking.",
                  },
                  expires_at: {
                    type: :string,
                    format: :datetime,
                    example: "2030-03-13T15:30:00Z",
                    description: "The end datetime of the vacancy. Must be after the start date.",
                  },
                  schools: {
                    oneOf: [
                      {
                        type: :object,
                        additionalProperties: false,
                        required: %i[trust_uid school_urns],
                        properties: {
                          trust_uid: {
                            type: :string,
                            example: "321",
                            description: "Unique identifier for a trust.",
                          },
                          school_urns: {
                            type: :array,
                            minItems: 0,
                            items: {
                              type: :string,
                              example: "12345",
                              description: "URNs of individual schools under the trust.",
                            },
                          },
                        },
                        description: "When providing a trust UID and school URNs, the vacancy will be associated with schools from the list that belong to the trust.",
                      },
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
                        description: "When providing only school URNs, the vacancy will be associated with the schools from the list.",
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
                        description: "When providing only a trust UID, the vacancy will be associated with the trust central office.",
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
                  contract_type: {
                    type: :string,
                    enum: Vacancy.contract_types.keys,
                    example: "permanent",
                    description: "The type of contract, e.g. 'permanent', 'fixed_term'.",
                  },
                  working_patterns: {
                    type: :array,
                    minItems: 1,
                    items: {
                      type: :string,
                      enum: Vacancy::WORKING_PATTERNS,
                      description: "Valid working pattern, e.g. 'full_time', 'part_time', etc.",
                    },
                    example: %w[full_time],
                    description: "An array of one or more working patterns for the vacancy.",
                  },
                  phases: {
                    type: :array,
                    minItems: 1,
                    items: {
                      type: :string,
                      enum: Vacancy.phases.keys,
                      description: "Valid phase, e.g. 'primary', 'secondary', etc.",
                    },
                    example: %w[secondary],
                    description: "One or more phases of education that the vacancy covers.",
                  },
                  salary: {
                    type: :string,
                    example: "£12,345 to £67,890",
                    description: "Compensation for the role.",
                  },
                  publish_on: {
                    type: :string,
                    format: :date,
                    example: "2025-01-01",
                    description: "The date on which the vacancy should be published. Defaults to the current date.",
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
                  ect_suitable: {
                    type: :boolean,
                    example: true,
                    description: "Indicates whether the vacancy is suitable for ECTs (Early Career Teachers).",
                  },
                  key_stages: {
                    type: :array,
                    minItems: 1,
                    items: {
                      type: :string,
                      enum: Vacancy.key_stages.keys,
                      description: "Valid key stage, e.g. 'ks1', 'ks2', etc.",
                    },
                    example: %w[ks1 ks2],
                    description: "One or more key stages relevant to the vacancy.",
                  },
                  subjects: {
                    type: :array,
                    minItems: 1,
                    items: {
                      type: :string,
                      enum: SUBJECT_OPTIONS.map(&:first), # List of available subjects in the service (from subjects.yml)
                      description: "Valid subject for the job, e.g. 'Biology', 'English', etc.",
                    },
                    example: %w[Mathematics Science],
                    description: "An array of subjects relevant to the vacancy.",
                  },
                },
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
                         publish_on
                         expires_at
                         job_advert
                         salary
                         benefits_details
                         starts_on
                         schools
                         job_roles
                         working_patterns
                         contract_type
                         phases
                         key_stages
                         subjects
                         is_job_share
                         ect_suitable
                         visa_sponsorship_available],
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
                type: :object,
                additionalProperties: false,
                required: %i[school_urns trust_uid],
                properties: {
                  school_urns: {
                    type: :array,
                    minItems: 0,
                    items: {
                      type: :string,
                      example: "123456",
                      description: "The unique reference number (URN) for an individual school.",
                    },
                  },
                  trust_uid: {
                    type: :string,
                    example: "12345",
                    description: "Unique identifier for a trust.",
                    nullable: true,
                  },
                },
                description: "Specifies which school(s) and/or trust the vacancy belongs to.",
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
            required: %i[vacancies meta], # Required so Rswag tests assert their presence in the API responses
            properties: {
              vacancies: {
                type: :array,
                description: "List of vacancies beonging to the client.",
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
            required: %w[errors],
            properties: {
              errors: {
                type: :array,
                items: {
                  type: :string,
                  description: "Error message describing the issue",
                },
                description: "One or more error messages describing the issue",
              },
            },
            example: {
              errors: ["param is missing or the value is empty: external_advert_url, expires_at"],
            },
            description: "Returned when the request is malformed or missing required parameters.",
          },
          unauthorized_error: {
            type: :object,
            required: %w[errors],
            properties: {
              errors: {
                type: :array,
                items: {
                  type: :string,
                  description: "Error message describing the issue",
                },
                description: "One or more error messages describing the issue",
              },
            },
            example: {
              errors: ["Invalid API key"],
            },
            description: "Returned when authentication fails",
          },
          not_found_error: {
            type: :object,
            required: %w[errors],
            properties: {
              errors: {
                type: :array,
                items: {
                  type: :string,
                  description: "Error message describing the issue",
                },
                description: "One or more error messages describing the issue",
              },
            },
            example: {
              errors: ["The given ID does not match any vacancy for your ATS"],
            },
            description: "Returned when the requested resource cannot be found",
          },
          internal_server_error: {
            type: :object,
            required: %w[errors],
            properties: {
              errors: {
                type: :array,
                items: {
                  type: :string,
                  description: "Error message describing the issue",
                },
                description: "One or more error messages describing the issue",
              },
            },
            example: {
              errors: ["There was an internal error processing this request"],
            },
            description: "Returned when an unexpected server error occurs",
          },
          conflict_error: {
            type: :object,
            required: %w[errors],
            properties: {
              errors: {
                type: :array,
                items: {
                  type: :string,
                  description: "Error message describing the issue",
                },
                description: "One or more error messages describing the issue",
              },
              meta: {
                type: :object,
                description: "Optional additional information about the error",
                properties: {
                  link: {
                    type: :string,
                    format: :uri,
                    description: "A link to an associated resource (when applicable)",
                  },
                },
                additionalProperties: true,
              },
            },
            example: {
              errors: ["A vacancy with the provided external reference already exists"],
              meta: {
                link: "https://example.com/vacancies/123",
              },
            },
            description: "Returned when a resource conflict occurs",
          },
          validation_error: {
            type: :object,
            required: %w[errors],
            properties: {
              errors: {
                type: :array,
                items: {
                  type: :string,
                  description: "Error message describing the issue",
                },
                description: "One or more error messages describing the issue",
              },
            },
            example: {
              errors: [
                "job_title: can't be blank",
                "salary: Enter full-time salary",
              ],
            },
            description: "Returned when submitted data fails validation",
          },
        },
      },
    },
  }

  config.openapi_format = :yaml
end
