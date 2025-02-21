require "swagger_helper"

# rubocop:disable RSpec/VariableName
# rubocop:disable RSpec/ScatteredSetup
# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe "ats-api/v1/vacancies", openapi_spec: "v1/swagger.yaml" do
  let!(:client) { create(:publisher_ats_api_client) }
  let(:"X-Api-Key") { client.api_key }

  path "/ats-api/v1/vacancies" do
    get(" Returns a paginated list of vacancies that were created through the client's ATS.") do
      tags "Vacancies"
      consumes "application/json"
      produces "application/json"

      security [api_key: []]
      parameter name: :page, in: :query, type: :number, description: "page number (1-based), defaults to 1"

      response(200, "Returns a list of paginated vacancies") do
        schema type: :object,
               required: %i[data meta],
               additionalProperties: false,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     "$ref" => "#/components/schemas/vacancy",
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
               }

        let(:page) { nil }
        let(:school) { create(:school) }

        before do
          Array.new(2) do |index|
            create(:vacancy, :external, publisher_ats_api_client: client, organisations: [school], external_reference: "REF_CLIENT_#{index}")
          end
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test!
      end

      response(401, "Occurs when the provided API key is incorrect or missing") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }
        let(:page) { nil }

        run_test!
      end

      response(500, "Indicates an unexpected issue on the server.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:page) { nil }

        before do
          allow(Vacancy).to receive(:live).and_raise(StandardError.new("Simulated server error"))
        end

        run_test!
      end
    end

    post("Creates a new vacancy for the client's ATS.") do
      tags "Vacancies"
      consumes "application/json"
      produces "application/json"

      security [api_key: []]

      parameter name: :vacancy, in: :body, schema: {
        type: :object,
        additionalProperties: false,
        required: %i[external_advert_url
                     expires_at
                     job_title
                     job_advert
                     skills_and_experience
                     salary
                     visa_sponsorship_available
                     external_reference
                     is_job_share
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
            description: "The date on which the vacancy should be published.",
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
            description: "The title of the vacancy.",
          },
          job_advert: { type: :string, example: "Aut repellat vel. Nesciunt exercitationem et. Numquam a corrupti. Et minus hic. Perspiciatis dolor neque. Sit est nemo. Ut ex officiis. Illum et mollitia. Quia qui qui. Debitis totam odio. Consequatur eum iste. Aut ex et. Quo explicabo quae. Aut id laborum. Occaecati quod sit. Laudantium ipsum placeat. Et sed nesciunt. Ut iste maxime. Ea repudiandae rem. Qui fugit adipisci. Vero fugiat dolor. Nesciunt eum et. Molestias nulla facere. Aliquid dolore assumenda. Aut repudiandae iusto. Quia aut maxime. Consequatur voluptates facere. Facere eius asperiores. Fugiat occaecati assumenda. Maiores consequatur architecto. Perferendis sint ut. Est odio dolorem. Aliquid fugiat iusto. Eaque fugiat voluptas. Eos velit assumenda. Nesciunt minus quia. Cupiditate vero dolor. Quos temporibus consequuntur. Vel cupiditate eos. Dolore dolores repellat. Ex ipsam consequuntur. Dolores harum voluptatem. Temporibus neque quis. Vero soluta sunt. Voluptas laboriosam modi. Quod ut nostrum. Veniam voluptatem et. Explicabo necessitatibus ex. Ut architecto placeat. Neque velit et." },
          skills_and_experience: {
            type: :string,
            example: "We're looking for a dedicated Teacher of Geography",
            description: "Details about the required skills, experience, and qualifications.",
          },
          salary: {
            type: :string,
            example: "£12,345 to £67,890",
            description: "Compensation for the role.",
          },
          benefits_details: {
            type: :string,
            example: "TLR2a",
            description: "Any additional benefits or allowances, e.g. TLR payments.",
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
            description: "Indicates if a visa sponsorship is available for this role.",
          },
          is_job_share: {
            type: :boolean,
            example: true,
            description: "Whether the role is open to a job share.",
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
              enum: Vacancy.working_patterns.keys,
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
      }

      response(201, "Indicates that the vacancy was created and returns the newly created resource.") do
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        schema "$ref" => "#/components/schemas/create_vacancy_response"

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:school_urns) { [school].map { |school| school.urn.to_i } }
        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: source.external_advert_url,
              expires_at: source.expires_at,
              job_title: source.job_title,
              job_advert: source.job_advert,
              skills_and_experience: source.skills_and_experience,
              salary: source.salary,
              visa_sponsorship_available: source.visa_sponsorship_available,
              external_reference: source.external_reference,
              publisher_ats_api_client_id: client.id,
              is_job_share: source.is_job_share,
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
              schools: {
                school_urns: school_urns,
              },
            },
          }
        end
        run_test!
      end

      response(400, "The request body is missing required parameters or has invalid data.") do
        schema "$ref" => "#/components/schemas/bad_request_error"

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:school_urns) { [school].map { |school| school.urn.to_i } }
        let(:vacancy) do
          {
            vacancy: {
              skills_and_experience: source.skills_and_experience,
              salary: source.salary,
              school_urns: school_urns,
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
            },
          }
        end
        run_test!
      end

      response(401, "Occurs when the provided API key is incorrect or missing.") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:vacancy) { {} }
        let(:"X-Api-Key") { "wrong-key" }

        run_test!
      end

      response(409, "An existing vacancy with the same external_reference already exists.") do
        schema "$ref" => "#/components/schemas/conflict_error"

        let(:school) { create(:school) }
        let(:source) { create(:vacancy, :external, external_reference: "Ext-ref", publisher_ats_api_client: client) }
        let(:school_urns) { [school].map { |school| school.urn.to_i } }
        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: source.external_advert_url,
              expires_at: source.expires_at,
              job_title: source.job_title,
              job_advert: source.job_advert,
              skills_and_experience: source.skills_and_experience,
              salary: source.salary,
              visa_sponsorship_available: source.visa_sponsorship_available,
              external_reference: source.external_reference,
              is_job_share: source.is_job_share,
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
              schools: {
                school_urns: school_urns,
              },
            },
          }
        end

        run_test!
      end

      response(422, "A server-side issue occurred while creating the vacancy.") do
        schema "$ref" => "#/components/schemas/validation_error"

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:school_urns) { [school].map { |school| school.urn.to_i } }
        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: source.external_advert_url,
              expires_at: source.expires_at,
              job_title: nil,
              job_advert: source.job_advert,
              skills_and_experience: source.skills_and_experience,
              salary: source.salary,
              visa_sponsorship_available: source.visa_sponsorship_available,
              external_reference: source.external_reference,
              is_job_share: source.is_job_share,
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
              schools: {
                school_urns: school_urns,
              },
            },
          }
        end

        run_test!
      end

      response(500, "A server-side issue occurred while creating the vacancy.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:school_urns) { [school].map { |school| school.urn.to_i } }
        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: source.external_advert_url,
              expires_at: source.expires_at,
              job_title: source.job_title,
              job_advert: source.job_advert,
              skills_and_experience: source.skills_and_experience,
              salary: source.salary,
              visa_sponsorship_available: source.visa_sponsorship_available,
              external_reference: source.external_reference,
              is_job_share: source.is_job_share,
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
              schools: {
                school_urns: school_urns,
              },
            },
          }
        end

        before do
          allow(Publishers::AtsApi::CreateVacancyService).to receive(:call).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end
  end

  path "/ats-api/v1/vacancies/{id}" do
    parameter name: "id", in: :path, type: :string, description: "The id of the vacancy"

    let(:id) { create(:vacancy, :external, publisher_ats_api_client: client).id }

    get("Retrieves details for a single vacancy by its unique ID, if it belongs to the requesting client.") do
      tags "Vacancies"
      consumes "application/json"
      produces "application/json"

      security [api_key: []]

      response(200, "Returns the vacancy's attributes in JSON format.") do
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        schema "$ref" => "#/components/schemas/vacancy"

        run_test!
      end

      response(401, "Occurs when the provided API key is incorrect or missing.") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }
        run_test!
      end

      response(404, "No vacancy was found with the provided ID that belongs to this client.") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }
        run_test!
      end

      response(500, "An unexpected error occurred on the server.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        before do
          allow(Vacancy).to receive(:find_by!).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end

    put("Updates an existing vacancy. The request body must include all required fields.") do
      tags "Vacancies"
      consumes "application/json"
      produces "application/json"

      security [api_key: []]

      parameter name: :vacancy, in: :body, schema: {
        type: :object,
        additionalProperties: false,
        required: %i[external_advert_url
                     expires_at
                     job_title
                     job_advert
                     skills_and_experience
                     salary
                     visa_sponsorship_available
                     external_reference
                     is_job_share
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
            description: "The date on which the vacancy should be published.",
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
            description: "The title of the vacancy.",
          },
          job_advert: { type: :string, example: "Aut repellat vel. Nesciunt exercitationem et. Numquam a corrupti. Et minus hic. Perspiciatis dolor neque. Sit est nemo. Ut ex officiis. Illum et mollitia. Quia qui qui. Debitis totam odio. Consequatur eum iste. Aut ex et. Quo explicabo quae. Aut id laborum. Occaecati quod sit. Laudantium ipsum placeat. Et sed nesciunt. Ut iste maxime. Ea repudiandae rem. Qui fugit adipisci. Vero fugiat dolor. Nesciunt eum et. Molestias nulla facere. Aliquid dolore assumenda. Aut repudiandae iusto. Quia aut maxime. Consequatur voluptates facere. Facere eius asperiores. Fugiat occaecati assumenda. Maiores consequatur architecto. Perferendis sint ut. Est odio dolorem. Aliquid fugiat iusto. Eaque fugiat voluptas. Eos velit assumenda. Nesciunt minus quia. Cupiditate vero dolor. Quos temporibus consequuntur. Vel cupiditate eos. Dolore dolores repellat. Ex ipsam consequuntur. Dolores harum voluptatem. Temporibus neque quis. Vero soluta sunt. Voluptas laboriosam modi. Quod ut nostrum. Veniam voluptatem et. Explicabo necessitatibus ex. Ut architecto placeat. Neque velit et." },
          skills_and_experience: {
            type: :string,
            example: "We're looking for a dedicated Teacher of Geography",
            description: "Details about the required skills, experience, and qualifications.",
          },
          salary: {
            type: :string,
            example: "£12,345 to £67,890",
            description: "Compensation for the role.",
          },
          benefits_details: {
            type: :string,
            example: "TLR2a",
            description: "Any additional benefits or allowances, e.g. TLR payments.",
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
            description: "Indicates if a visa sponsorship is available for this role.",
          },
          is_job_share: {
            type: :boolean,
            example: true,
            description: "Whether the role is open to a job share.",
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
              enum: Vacancy.working_patterns.keys,
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
      }

      response(200, "Indicates the vacancy was updated. Returns the updated resource data.") do
        schema "$ref" => "#/components/schemas/vacancy"

        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: "https://example.com/jobs/123",
              expires_at: "2022-01-01",
              job_title: "Teacher of Geography",
              job_advert: "Teacher of Geography",
              skills_and_experience: "We're looking for a dedicated Teacher of Geography",
              salary: "£12,345 to £67,890",
              visa_sponsorship_available: true,
              external_reference: "REF1234HYZ",
              is_job_share: true,
              job_roles: %w[teacher],
              working_patterns: %w[full_time],
              contract_type: "permanent",
              phases: %w[secondary],
              schools: {
                school_urns: [create(:school).urn],
              },
            },
          }
        end

        run_test!
      end

      response(400, "Missing or invalid fields in the request body.") do
        schema "$ref" => "#/components/schemas/bad_request_error"

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:school_urns) { [school].map { |school| school.urn.to_i } }
        let(:vacancy) do
          {
            vacancy: {
              skills_and_experience: source.skills_and_experience,
              salary: source.salary,
              school_urns: school_urns,
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
            },
          }
        end

        run_test!
      end

      response(401, "Occurs when the provided API key is incorrect or missing.") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:vacancy) { {} }

        let(:"X-Api-Key") { "wrong-key" }
        run_test!
      end

      response(404, "No vacancy was found with the provided ID that belongs to this client.") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }

        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: "https://example.com/jobs/123",
              expires_at: "2022-01-01",
              job_title: "Teacher of Geography",
              job_advert: "Teacher of Geography",
              skills_and_experience: "We're looking for a dedicated Teacher of Geography",
              salary: "£12,345 to £67,890",
              visa_sponsorship_available: true,
              external_reference: "REF1234HYZ",
              is_job_share: true,
              job_roles: %w[teacher],
              working_patterns: %w[full_time],
              contract_type: "permanent",
              phases: %w[secondary],
              schools: {
                school_urns: [create(:school).urn],
              },
            },
          }
        end
        run_test!
      end

      response(422, "The payload is syntactically correct but fails a data validation rule.") do
        schema "$ref" => "#/components/schemas/validation_error"

        let(:id) { create(:vacancy, :external, publisher_ats_api_client: client).id }

        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: "https://example.com/jobs/123",
              expires_at: "2022-01-01",
              job_title: nil,
              job_advert: nil,
              skills_and_experience: "We're looking for a dedicated Teacher of Geography",
              salary: "£12,345 to £67,890",
              visa_sponsorship_available: true,
              external_reference: "REF1234HYZ",
              is_job_share: true,
              job_roles: %w[teacher],
              working_patterns: %w[full_time],
              contract_type: "permanent",
              phases: %w[secondary],
              schools: {
                school_urns: [create(:school).urn],
              },
            },
          }
        end
        run_test!
      end

      response(500, "An unexpected error occurred on the server.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: "https://example.com/jobs/123",
              expires_at: "2022-01-01",
              job_title: "Teacher of Geography",
              job_advert: "Teacher of Geography",
              skills_and_experience: "We're looking for a dedicated Teacher of Geography",
              salary: "£12,345 to £67,890",
              visa_sponsorship_available: true,
              external_reference: "REF1234HYZ",
              is_job_share: true,
              job_roles: %w[teacher],
              working_patterns: %w[full_time],
              contract_type: "permanent",
              phases: %w[secondary],
              schools: {
                school_urns: [create(:school).urn],
              },
            },
          }
        end

        before do
          allow(Vacancy).to receive(:find_by!).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end

    delete("Deletes a vacancy with the given ID, if it belongs to the client's ATS. Returns 204 on success.") do
      tags "Vacancies"
      consumes "application/json"

      security [api_key: []]

      response(204, "Indicates the vacancy was removed from the system.") do
        run_test!
      end

      response(401, "Occurs when the provided API key is incorrect or missing.") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }
        run_test!
      end

      response(404, "No vacancy was found with the provided ID that belongs to this client.") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }
        run_test!
      end

      response(500, "An unexpected error occurred on the server.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        before do
          allow(Vacancy).to receive(:find_by!).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end
  end
end
# rubocop:enable RSpec/VariableName
# rubocop:enable RSpec/ScatteredSetup
# rubocop:enable RSpec/EmptyExampleGroup
