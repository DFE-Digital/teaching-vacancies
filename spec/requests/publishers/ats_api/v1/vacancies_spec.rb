require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
# rubocop:disable RSpec/ScatteredSetup
RSpec.describe "ats-api/v1/vacancies" do
  path "/ats-api/v{api_version}/vacancies" do
    parameter name: "api_version", in: :path, type: :string, description: "api_version"

    get("list vacancies") do
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:api_version) { "1" }
        let(:page) { nil }

        before do
          create(:vacancy, :external)
        end

        parameter name: :page, in: :query, type: :number, description: "page number (1-based), defaults to 1"

        schema type: :object,
               required: %i[data meta],
               additionalProperties: false,
               properties: {
                 data: {
                   type: :array,
                   items: {
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
                                   type: :integer,
                                   example: 12_345,
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
                                 type: :integer,
                                 example: 12_345,
                               },
                               school_urns: {
                                 type: :array,
                                 minItems: 0,
                                 items: {
                                   type: :integer,
                                   example: 12_345,
                                 },
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

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test!
      end
    end

    post("create vacancy") do
      consumes "application/json"
      produces "application/json"

      parameter name: :vacancy, in: :body, schema: {
        type: :object,
        additionalProperties: false,
        required: %i[external_advert_url
                     expires_at
                     job_title
                     skills_and_experience
                     salary
                     visa_sponsorship_available
                     reference
                     is_job_share
                     job_roles
                     working_patterns
                     contract_type
                     phase
                     schools],
        properties: {
          external_advert_url: { type: :string, example: "https://example.com/jobs/123" },
          publish_on: { type: :string, format: :date },
          expires_at: { type: :string, format: :date },
          job_title: { type: :string, example: "Teacher of Geography" },
          skills_and_experience: { type: :string, example: "We're looking for a dedicated Teacher of Geography" },
          salary: { type: :string, example: "£12,345 to £67,890" },
          benefits_details: { type: :string, example: "TLR2a" },
          starts_on: { type: :string, example: "Easter Term" },
          external_reference: { type: :string, example: "REF1234HYZ" },
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
                      type: :integer,
                      example: 12_345,
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
                    type: :integer,
                    example: 12_345,
                  },
                  school_urns: {
                    type: :array,
                    minItems: 0,
                    items: {
                      type: :integer,
                      example: 12_345,
                    },
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
            description: "Whether or not this role is suitable for early career teachers (ECT). Defaults to false if not supplied",
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
      }

      response(201, "successful") do
        let(:api_version) { "1" }

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:vacancy) do
          { vacancy: { external_advert_url: source.external_advert_url,
                       expires_at: source.expires_at,
                       job_title: source.job_title,
                       skills_and_experience: source.skills_and_experience,
                       salary: source.salary,
                       school_urns: [school].map { |x| x.urn.to_i },
                       job_roles: source.job_roles,
                       working_patterns: source.working_patterns,
                       contract_type: source.contract_type,
                       phases: source.phases } }
        end
        run_test!
      end

      response(400, "error") do
        let(:api_version) { "1" }

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        schema type: :object,
               additionalProperties: false,
               properties: {
                 errors: {
                   type: :object,
                   properties: {
                     organisations: {
                       type: :array,
                       minItems: 1,
                       items: {
                         type: :string,
                       },
                     },
                   },
                 },
               }

        let(:source) { build(:vacancy) }
        let(:vacancy) do
          { vacancy: { external_advert_url: source.external_advert_url,
                       expires_at: source.expires_at,
                       job_title: source.job_title,
                       skills_and_experience: source.skills_and_experience,
                       salary: source.salary,
                       school_urns: [],
                       job_roles: source.job_roles,
                       working_patterns: source.working_patterns,
                       contract_type: source.contract_type,
                       phases: source.phases } }
        end
        run_test!
      end
    end
  end

  path "/ats-api/v{api_version}/vacancies/{id}" do
    parameter name: "api_version", in: :path, type: :string, description: "api_version"
    parameter name: "id", in: :path, type: :string, description: "id of the vacancy"

    let(:id) { create(:vacancy, :external).id }

    get("show vacancy") do
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:api_version) { "1" }

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        schema type: :object,
               additionalProperties: false,
               properties: {
                 id: { type: :string },
                 external_advert_url: { type: :string },
                 publish_on: { type: :string },
                 expires_at: { type: :string },
                 job_title: { type: :string },
                 skills_and_experience: { type: :string },
                 salary: { type: :string },
                 benefits_details: { type: :string },
                 starts_on: { type: :string },
                 external_reference: { type: :string },
                 visa_sponsorship_available: { type: :boolean },
                 ect_suitable: { type: :boolean },
                 is_job_share: { type: :boolean },
                 job_roles: {
                   type: :array,
                   minItems: 1,
                   items: {
                     type: :string,
                     enum: Vacancy.job_roles.keys,
                   },
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
                 subjects: {
                   type: :array,
                   minItems: 1,
                 },
                 schools: {
                   type: :object,
                   additionalProperties: false,
                   properties: {
                     school_urns: {
                       type: :array,
                       minItems: 1,
                       items: { type: :integer },
                     },
                   },
                 },
               }

        run_test!
      end
    end

    put("update vacancy") do
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:api_version) { "1" }

        run_test!
      end
    end

    delete("delete vacancy") do
      consumes "application/json"

      response(204, "successful") do
        let(:api_version) { "1" }

        run_test!
      end
    end
  end
end
# rubocop:enable RSpec/ScatteredSetup
# rubocop:enable RSpec/EmptyExampleGroup
