require "swagger_helper"

RSpec.describe "api/v2/vacancies", type: :request do
  path "/api/v{api_version}/vacancies" do
    parameter name: "api_version", in: :path, type: :string, description: "api_version"

    get("list vacancies") do
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:api_version) { "2" }

        before do
          create(:vacancy, :external)
        end

        schema type: :object,
               additionalProperties: false,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     additionalProperties: false,
                     required: %i[advertUrl expiresAt jobTitle jobAdvert salaryRange schoolUrns jobRoles workingPatterns contractType phase],
                     properties: {
                       advertUrl: { type: :string, example: "https://example.com/jobs/123" },
                       publishOn: { type: :string, format: :date },
                       expiresAt: { type: :string, format: :date },
                       jobTitle: { type: :string, example: "Teacher of Geography" },
                       jobAdvert: { type: :string, example: "We're looking for a dedicated Teacher of Geography" },
                       salaryRange: { type: :string, example: "£12,345 to £67, 890" },
                       additionalAllowances: { type: :string, example: "TLR2a" },
                       startDate: { type: :string, example: "Easter Term" },
                       schoolUrns: {
                         type: :array,
                         minItems: 1,
                         items: {
                           type: :integer,
                           example: 12_345,
                         },
                       },
                       trustUid: {
                         type: :integer,
                         example: 12_345,
                       },
                       jobRoles: {
                         type: :array,
                         minItems: 1,
                         items: {
                           type: :string,
                           enum: %i[teacher head_of_year_or_phase head_of_department_or_curriculum assistant_headteacher
                                    deputy_headteacher headteacher teaching_assistant higher_level_teaching_assistant education_support sendco other_teaching_support
                                    administration_hr_data_and_finance catering_cleaning_and_site_management it_support pastoral_health_and_welfare
                                    other_leadership other_support],
                         },
                       },
                       ectSuitable: {
                         type: :boolean,
                       },
                       workingPatterns: {
                         type: :array,
                         minItems: 1,
                         items: {
                           type: :string,
                           enum: %i[full_time part_time flexible job_share term_time],
                         },
                       },
                       contractType: {
                         type: :string,
                         enum: %i[permanent fixed_term parental_leave_cover],
                       },
                       phase: {
                         type: :string,
                         enum: %i[nursery primary middle secondary sixth_form_or_college through],
                       },
                       keyStages: {
                         type: :array,
                         minItems: 1,
                         items: {
                           type: :string,
                           enum: %i[early_years ks1 ks2 ks3 ks4 ks5],
                         },
                       },
                       subjects: {
                         type: :array,
                         minItems: 1,
                         items: {
                           type: :string,
                           enum: ["Accounting", "Art and design", "biology", "business_studies", "chemistry", "citizenship", "classics",
                                  "computing", "dance", "design_and_technology", "drama", "economics", "engineering", "english",
                                  "food_technology", "french", "geography", "german", "health_and_social_care", "history",
                                  "humanities", "ict", "languages", "law", "mandarin", "mathematics", "media_studies", "music",
                                  "philosophy", "physical_education", "physics", "pshe", "psychology", "religious_education",
                                  "science", "social_science", "sociology", "spanish", "statistics"],
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
        required: %i[advertUrl expiresAt jobTitle jobAdvert salaryRange schoolUrns jobRoles workingPatterns contractType phase],
        properties: {
          advertUrl: { type: :string, example: "https://example.com/jobs/123" },
          publishOn: { type: :string, format: :date },
          expiresAt: { type: :string, format: :date },
          jobTitle: { type: :string, example: "Teacher of Geography" },
          jobAdvert: { type: :string, example: "We're looking for a dedicated Teacher of Geography" },
          salaryRange: { type: :string, example: "£12,345 to £67, 890" },
          additionalAllowances: { type: :string, example: "TLR2a" },
          startDate: { type: :string, example: "Easter Term" },
          schoolUrns: {
            type: :array,
            minItems: 1,
            items: {
              type: :integer,
              example: 12_345,
            },
          },
          trustUid: {
            type: :integer,
            example: 12_345,
          },
          jobRoles: {
            type: :array,
            minItems: 1,
            items: {
              type: :string,
              enum: %i[teacher head_of_year_or_phase head_of_department_or_curriculum assistant_headteacher deputy_headteacher
                         headteacher teaching_assistant higher_level_teaching_assistant education_support sendco other_teaching_support
                         administration_hr_data_and_finance catering_cleaning_and_site_management it_support pastoral_health_and_welfare
                         other_leadership other_support],
            },
          },
          ectSuitable: {
            type: :boolean,
          },
          workingPatterns: {
            type: :array,
            minItems: 1,
            items: {
              type: :string,
              enum: %i[full_time part_time flexible job_share term_time],
            },
          },
          contractType: {
            type: :string,
            enum: %i[permanent fixed_term parental_leave_cover],
          },
          phase: {
            type: :string,
            enum: %i[nursery primary middle secondary sixth_form_or_college through],
          },
          keyStages: {
            type: :array,
            minItems: 1,
            items: {
              type: :string,
              enum: %i[early_years ks1 ks2 ks3 ks4 ks5],
            },
          },
          subjects: {
            type: :array,
            minItems: 1,
            items: {
              type: :string,
              enum: ["Accounting", "Art and design", "biology", "business_studies", "chemistry", "citizenship", "classics",
                     "computing", "dance", "design_and_technology", "drama", "economics", "engineering", "english",
                     "food_technology", "french", "geography", "german", "health_and_social_care", "history",
                     "humanities", "ict", "languages", "law", "mandarin", "mathematics", "media_studies", "music",
                     "philosophy", "physical_education", "physics", "pshe", "psychology", "religious_education",
                     "science", "social_science", "sociology", "spanish", "statistics"],
            },
          },
        },
      }

      response(200, "successful") do
        let(:api_version) { "2" }

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        let(:school) { create(:school) }
        let(:source) { build(:vacancy) }
        let(:vacancy) do
          { vacancy: { advertUrl: source.external_advert_url,
                       expiresAt: source.expires_at,
                       jobTitle: source.job_title,
                       jobAdvert: source.skills_and_experience,
                       salaryRange: source.salary,
                       schoolUrns: [school].map(&:urn).map(&:to_i),
                       jobRoles: source.job_roles,
                       workingPatterns: source.working_patterns,
                       contractType: source.contract_type,
                       phase: source.phases.first } }
        end
        run_test!
      end
    end
  end

  path "/api/v{api_version}/vacancies/{id}" do
    parameter name: "api_version", in: :path, type: :string, description: "api_version"
    parameter name: "id", in: :path, type: :string, description: "id"

    get("show vacancy") do
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:api_version) { "2" }
        let(:id) { "123" }

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

    put("update vacancy") do
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:api_version) { "2" }
        let(:id) { "123" }

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

    delete("delete vacancy") do
      consumes "application/json"
      produces "application/json"

      response(204, "successful") do
        let(:api_version) { "2" }
        let(:id) { "123" }

        # after do |example|
        #   example.metadata[:response][:content] = {
        #     "application/json" => {
        #       example: JSON.parse(response.body, symbolize_names: true),
        #     },
        #   }
        # end
        run_test!
      end
    end
  end
end
