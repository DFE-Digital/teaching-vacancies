require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
# rubocop:disable RSpec/ScatteredSetup
# rubocop:disable RSpec/VariableName
RSpec.describe "ats-api/v1/vacancies", openapi_spec: "v1/swagger.yaml" do
  let!(:client) { create(:publisher_ats_api_client) }
  let(:"X-Api-Key") { client.api_key }

  path "/ats-api/v1/vacancies" do
    get("list vacancies") do
      tags "Vacancies"
      description "list all the vacancies created from the client's ATS"

      consumes "application/json"
      produces "application/json"

      security [api_key: []]
      parameter name: :page, in: :query, type: :number, description: "page number (1-based), defaults to 1"

      response(200, "vacancies successfully listed") do
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

        before do
          create(:vacancy, :external)
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

      response(401, "Invalid credentials") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }
        let(:page) { nil }

        run_test!
      end

      response(500, "Internal server error") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        before do
          allow(Vacancy).to receive(:find).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end

    post("create a vacancy") do
      tags "Vacancies"
      description "create a vacancy for the client's ATS"

      consumes "application/json"
      produces "application/json"

      security [api_key: []]

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

      response(201, "vacancy successfully created") do
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        schema "$ref" => "#/components/schemas/vacancy"

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

      response(400, "Bad Request error") do
        schema "$ref" => "#/components/schemas/bad_request_error"

        run_test!
      end

      response(401, "Invalid credentials") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }

        run_test!
      end

      response(422, "Validation error") do
        schema "$ref" => "#/components/schemas/validation_error"

        let(:vacancy) do
          { vacancy: { external_advert_url: nil, job_title: nil } }
        end
        run_test!
      end

      response(500, "Internal server error") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        before do
          allow(Vacancy).to receive(:find).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end
  end

  path "/ats-api/v1/vacancies/{id}" do
    parameter name: "id", in: :path, type: :string, description: "id of the vacancy"

    let(:id) { create(:vacancy, :external).id }

    get("show vacancy") do
      tags "Vacancies"
      description "show the vacancy with the given id"

      consumes "application/json"
      produces "application/json"

      security [api_key: []]

      response(200, "vacancy successfully retrieved") do
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

      response(401, "Invalid credentials") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }
        run_test!
      end

      response(404, "Vacancy not found") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }
        run_test!
      end

      response(500, "Internal server error") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:id) { "123" }

        before do
          allow(Vacancy).to receive(:find).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end

    put("update vacancy") do
      tags "Vacancies"
      description "update the vacancy with the given id"

      consumes "application/json"
      produces "application/json"

      security [api_key: []]

      response(200, "vacancy successfully updated") do
        schema "$ref" => "#/components/schemas/vacancy"

        run_test!
      end

      response(400, "Bad Request error") do
        schema "$ref" => "#/components/schemas/bad_request_error"

        run_test!
      end

      response(401, "Invalid credentials") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }
        run_test!
      end

      response(404, "Vacancy not found") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }
        run_test!
      end

      response(422, "Validation error") do
        schema "$ref" => "#/components/schemas/validation_error"

        let(:id) { create(:vacancy, :external).id }
        let(:vacancy) do
          { vacancy: { external_advert_url: nil, job_title: nil } }
        end
        run_test!
      end

      response(500, "Internal server error") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:id) { "123" }

        before do
          allow(Vacancy).to receive(:find).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end

    delete("delete vacancy") do
      tags "Vacancies"
      description "update the vacancy with the given id"

      consumes "application/json"

      security [api_key: []]

      response(204, "vacancy successfully deleted") do
        run_test!
      end

      response(401, "Invalid credentials") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }
        run_test!
      end

      response(404, "Vacancy not found") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }
        run_test!
      end

      response(500, "Internal server error") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:id) { "123" }

        before do
          allow(Vacancy).to receive(:find).and_raise(StandardError.new("Internal server error"))
        end

        run_test!
      end
    end
  end
end
# rubocop:enable RSpec/VariableName
# rubocop:enable RSpec/ScatteredSetup
# rubocop:enable RSpec/EmptyExampleGroup
