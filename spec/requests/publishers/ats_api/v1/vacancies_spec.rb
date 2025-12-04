require "swagger_helper"

# rubocop:disable RSpec/VariableName
# rubocop:disable RSpec/ScatteredSetup
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

      response(200, "Returns a paginated list of all the client vacancies") do
        schema "$ref" => "#/components/schemas/vacancies_response"

        let(:page) { nil }
        let(:school) { create(:school) }
        let(:other_client) { create(:publisher_ats_api_client) }
        let!(:vacancy_published) do
          create(:vacancy, :external, :past_publish, publisher_ats_api_client: client, organisations: [school], external_reference: "REF_CLIENT_0")
        end
        let!(:vacancy_unpublished) do
          create(:vacancy, :external, :future_publish, publisher_ats_api_client: client, organisations: [school], external_reference: "REF_CLIENT_1")
        end
        let!(:vacancy_expired) do
          create(:vacancy, :external, :expired, publisher_ats_api_client: client, organisations: [school], external_reference: "REF_CLIENT_2")
        end

        before do
          create(:vacancy, :external, :trashed, publisher_ats_api_client: client, organisations: [school], external_reference: "REF_CLIENT_3")
          Array.new(3) do |index|
            create(
              :vacancy,
              :external,
              publisher_ats_api_client: other_client,
              organisations: [school],
              external_reference: "REF_OTHER_CLIENT_#{index}",
            )
          end
        end

        # Autogenerate documentation examples from response
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test! do |response|
          body = response.parsed_body
          expect(body.keys).to match_array(%w[vacancies meta])
          # Contain all the client vacancies
          expect(body["vacancies"].pluck("external_reference")).to contain_exactly(vacancy_published.external_reference,
                                                                                   vacancy_unpublished.external_reference,
                                                                                   vacancy_expired.external_reference)
          expect(body["meta"]["totalPages"]).to eq(1)
        end
      end

      response(401, "Occurs when the provided API key is incorrect or missing") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }
        let(:page) { nil }

        run_test! do |response|
          expect(response.parsed_body).to eq({ "errors" => ["Invalid API key"] })
        end
      end

      response(500, "Indicates an unexpected issue on the server.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:page) { nil }
        let(:exception) { StandardError.new("Simulated server error") }

        before do
          allow(Sentry).to receive(:capture_exception)
          allow(Vacancy).to receive(:includes).and_raise(exception)
        end

        run_test! do |response|
          expect(Sentry).to have_received(:capture_exception).with(exception)
          expect(response.parsed_body).to eq({ "errors" => ["There was an internal error processing this request"] })
        end
      end
    end

    post("Creates a new vacancy for the client's ATS.") do
      tags "Vacancies"
      consumes "application/json"
      produces "application/json"

      security [api_key: []]

      parameter name: :vacancy, in: :body, schema: { "$ref" => "#/components/schemas/vacancy_request" }

      response(201, "Indicates that the vacancy was created and returns the newly created resource.") do
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        schema "$ref" => "#/components/schemas/create_vacancy_response"

        let(:source) { build(:vacancy, :external) }
        let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
        let(:schools) { [school1] }
        let(:organisation_ids) do
          {
            school_urns: schools.map(&:urn),
          }
        end
        let(:vacancy_params) do
          {
            external_advert_url: "https://www.example.com/ats-site/advertid",
            expires_at: "2026-01-01",
            job_title: "Teacher of Geography",
            job_advert: "We're looking for a dedicated Teacher of Geography",
            salary: "£12,345 to £67,890",
            visa_sponsorship_available: true,
            external_reference: "REF1234HYZ",
            ect_suitable: true,
            job_roles: %w[teacher],
            is_job_share: false,
            working_patterns: %w[full_time],
            contract_type: "permanent",
            phases: %w[secondary],
            publish_on: (Time.zone.today + 1).strftime("%Y-%m-%d"),
            schools: organisation_ids,
            subjects: %w[Biology],
            key_stages: %w[ks1 ks2],
            starts_on: "Next April",
          }
        end
        let(:vacancy) { { vacancy: vacancy_params } }

        it "creates a published vacancy with the given values" do |example|
          expect { submit_request(example.metadata) }.to change(Vacancy, :count).from(0).to(1)
          assert_response_matches_metadata(example.metadata)
          created_vacancy = Vacancy.last
          expect(response.parsed_body).to eq("id" => created_vacancy.id)
          expect(created_vacancy).to have_attributes(
            external_advert_url: "https://www.example.com/ats-site/advertid",
            expires_at: Date.new(2026, 1, 1),
            job_title: "Teacher of Geography",
            job_advert: "We're looking for a dedicated Teacher of Geography",
            salary: "£12,345 to £67,890",
            visa_sponsorship_available: true,
            external_reference: "REF1234HYZ",
            ect_status: "ect_suitable",
            job_roles: %w[teacher],
            is_job_share: false,
            working_patterns: %w[full_time],
            contract_type: "permanent",
            phases: %w[secondary],
            subjects: %w[Biology],
            key_stages: %w[ks1 ks2],
            publish_on: Time.zone.today + 1,
            starts_on: nil,
            start_date_type: "other",
            other_start_date_details: "Next April",
          )
        end

        context "when subjects and key_stages are empty arrays", document: false do
          let(:vacancy_params) do
            {
              external_advert_url: "https://www.example.com/ats-site/advertid",
              expires_at: "2026-01-01",
              job_title: "Headteacher",
              job_advert: "An exciting opportunity for a headteacher",
              salary: "£70,000 to £90,000",
              visa_sponsorship_available: false,
              external_reference: "HEAD123",
              ect_suitable: false,
              job_roles: %w[headteacher],
              is_job_share: false,
              working_patterns: %w[full_time],
              contract_type: "permanent",
              phases: %w[primary],
              publish_on: (Time.zone.today + 1).strftime("%Y-%m-%d"),
              schools: {
                school_urns: [school1.urn],
              },
              subjects: [],
              key_stages: [],
              starts_on: "Next September",
            }
          end
          let(:vacancy) { { vacancy: vacancy_params } }

          it "creates the vacancy with empty subjects" do |example|
            expect { submit_request(example.metadata) }.to change(Vacancy, :count).by(1)
            assert_response_matches_metadata(example.metadata)

            created_vacancy = Vacancy.last
            expect(created_vacancy.subjects).to eq([])
            expect(created_vacancy.key_stages).to eq([])
            expect(created_vacancy.job_roles).to eq(%w[headteacher])
          end
        end

        describe "organisation linking", document: false do
          let(:created_vacancy) { Vacancy.last }

          describe "with a single school" do
            it "links the vacancy to a single school" do |example|
              submit_request(example.metadata)
              assert_response_matches_metadata(example.metadata)
              expect(created_vacancy.organisations).to eq([school1])
            end
          end

          describe "with multiple schools" do
            let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
            let(:schools) { [school1, school2] }

            it "links the vacancy to multiple schools" do |example|
              submit_request(example.metadata)
              assert_response_matches_metadata(example.metadata)
              expect(created_vacancy.organisations.sort).to eq([school1, school2].sort)
            end
          end

          describe "with a trust central office and no schools" do
            let(:organisation_ids) do
              {
                trust_uid: school_group.uid,
              }
            end
            let(:school_group) { create(:trust, uid: "12345") }

            it "links the vacancy to the trust" do |example|
              submit_request(example.metadata)
              assert_response_matches_metadata(example.metadata)
              expect(created_vacancy.organisations).to eq([school_group])
            end
          end

          describe "with a trust central office and some schools" do
            let(:organisation_ids) do
              {
                trust_uid: school_group.uid,
                school_urns: schools.map(&:urn),
              }
            end

            let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
            let(:schools) { [school1, school2] }

            let(:school_group) { create(:trust, uid: "12345", schools: schools) }

            it "links the vacancy to the trusts schools" do |example|
              submit_request(example.metadata)
              assert_response_matches_metadata(example.metadata)
              expect(created_vacancy.organisations.sort).to eq([school1, school2].sort)
            end
          end
        end

        context "when not providing the optional parameters", document: false do
          let(:vacancy_params) do
            super().except(:publish_on,
                           :benefits_details,
                           :starts_on,
                           :visa_sponsorship_available,
                           :is_job_share,
                           :ect_suitable,
                           :key_stages,
                           :subjects)
          end

          it "creates a published vacancy with default values for the not provided parameters" do |example|
            expect { submit_request(example.metadata) }.to change(Vacancy, :count).from(0).to(1)
            assert_response_matches_metadata(example.metadata)
            created_vacancy = Vacancy.last
            expect(response.parsed_body).to eq("id" => created_vacancy.id)
            expect(created_vacancy).to have_attributes(
              publish_on: Time.zone.today,
              benefits_details: nil,
              starts_on: nil,
              start_date_type: nil,
              other_start_date_details: nil,
              visa_sponsorship_available: false,
              is_job_share: false,
              ect_status: "ect_unsuitable",
              key_stages: [],
              subjects: nil,
            )
          end
        end
      end

      response(400, "The request body is missing required parameters or has invalid data.") do
        schema "$ref" => "#/components/schemas/bad_request_error"

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:school_urns) { [school].map(&:urn) }
        let(:vacancy) do
          {
            vacancy: {
              expires_at: source.expires_at,
              job_advert: source.job_advert,
              salary: source.salary,
              schools: { school_urns: school_urns },
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
            },
          }
        end

        it "list the missing parameters" do |example|
          submit_request(example.metadata)
          assert_response_matches_metadata(example.metadata)
          expect(response.parsed_body.keys).to eq(%w[errors])
          expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
            .to contain_exactly("The property '#/vacancy' did not contain a required property of 'external_advert_url'",
                                "The property '#/vacancy' did not contain a required property of 'job_title'",
                                "The property '#/vacancy' did not contain a required property of 'external_reference'")
        end

        context "when the request has a completely empty body", document: false do
          let(:vacancy) { nil }
          let(:empty_params) do
            ActionController::Parameters.new({ "controller" => "publishers/ats_api/v1/vacancies", "action" => "create" })
          end

          # Explicitly override the standard parameter processing to stub "vacancy" key not being present
          before do
            allow_any_instance_of(Publishers::AtsApi::V1::VacanciesController).to receive(:params) # rubocop:disable RSpec/AnyInstance
              .and_return(empty_params)
          end

          it "lists the missing vacancy parameter" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body.keys).to eq(%w[errors])
            expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
              .to contain_exactly("The property '#/' did not contain a required property of 'vacancy'")
          end
        end

        context "when the request contains params outside the vacancy param" do
          let(:vacancy) { nil }
          let(:wrong_params) do
            ActionController::Parameters.new({ "controller" => "publishers/ats_api/v1/vacancies",
                                               "action" => "create",
                                               "expires_at" => source.expires_at,
                                               "job_advert" => source.job_advert })
          end

          # Explicitly override the standard parameter processing to stub "vacancy" key not being present
          before do
            allow_any_instance_of(Publishers::AtsApi::V1::VacanciesController).to receive(:params) # rubocop:disable RSpec/AnyInstance
              .and_return(wrong_params)
          end

          it "lists the missing vacancy parameter" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body.keys).to eq(%w[errors])
            expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
              .to contain_exactly("The property '#/' did not contain a required property of 'vacancy'")
          end
        end

        context "when the request contains only the main vacancy parameter but no params within it", document: false do
          let(:vacancy) { { vacancy: {} } }

          it "lists all the missing parameters" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body.keys).to eq(%w[errors])
            expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
              .to contain_exactly("The property '#/vacancy' did not contain a required property of 'external_advert_url'",
                                  "The property '#/vacancy' did not contain a required property of 'expires_at'",
                                  "The property '#/vacancy' did not contain a required property of 'job_title'",
                                  "The property '#/vacancy' did not contain a required property of 'job_advert'",
                                  "The property '#/vacancy' did not contain a required property of 'salary'",
                                  "The property '#/vacancy' did not contain a required property of 'external_reference'",
                                  "The property '#/vacancy' did not contain a required property of 'job_roles'",
                                  "The property '#/vacancy' did not contain a required property of 'working_patterns'",
                                  "The property '#/vacancy' did not contain a required property of 'contract_type'",
                                  "The property '#/vacancy' did not contain a required property of 'phases'",
                                  "The property '#/vacancy' did not contain a required property of 'schools'")
          end
        end

        context "when the request is malformed", document: false do
          let(:vacancy) do
            {
              vacancy: {
                external_advert_url: source.external_advert_url,
                expires_at: source.expires_at,
                job_title: source.job_title,
                job_advert: source.job_advert,
                external_reference: source.external_reference,
                salary: source.salary,
                schools: { school_urns: school_urns },
                job_roles: source.job_roles,
                working_patterns: source.working_patterns,
                contract_type: source.contract_type,
                phases: ["any old phase"],
              },
            }
          end

          it "describes the error" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body.keys).to eq(%w[errors])
            expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
              .to eq(["The property '#/vacancy/phases/0' value \"any old phase\" did not match one of the following values: nursery, primary, secondary, sixth_form_or_college, through"])
          end
        end
      end

      response(401, "Occurs when the provided API key is incorrect or missing.") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:vacancy) { {} }
        let(:"X-Api-Key") { "wrong-key" }

        run_test! do |response|
          expect(response.parsed_body).to eq({ "errors" => ["Invalid API key"] })
        end
      end

      response(409, "An existing vacancy with the same external reference already exists.") do
        schema "$ref" => "#/components/schemas/conflict_error"

        let(:school) { create(:school) }
        let(:source) { create(:vacancy, :external, external_reference: "Ext-ref", publisher_ats_api_client: client) }
        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: source.external_advert_url,
              expires_at: source.expires_at,
              job_title: source.job_title,
              job_advert: source.job_advert,
              salary: source.salary,
              visa_sponsorship_available: source.visa_sponsorship_available,
              external_reference: source.external_reference,
              is_job_share: source.is_job_share,
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
              schools: {
                school_urns: [school.urn],
              },
            },
          }
        end

        run_test! do |response|
          expect(response.parsed_body.keys).to match_array(%w[errors meta])
          expect(response.parsed_body["errors"]).to eq(["A vacancy with the provided ATS client ID and external reference already exists."])
          expect(response.parsed_body["meta"]["link"]).to end_with("/ats-api/v1/vacancies/#{source.id}")
        end
      end

      response(422, "One or more values failed validation.") do
        schema "$ref" => "#/components/schemas/validation_error"

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:school_urns) { [school].map(&:urn) }
        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: source.external_advert_url,
              expires_at: source.expires_at,
              job_title: "",
              job_advert: source.job_advert,
              salary: "",
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

        it "list the failed validations" do |example|
          submit_request(example.metadata)
          assert_response_matches_metadata(example.metadata)
          expect(response.parsed_body).to eq(
            { "errors" => ["job_title: can't be blank", "salary: Enter full-time salary"] },
          )
        end
      end

      response(500, "A server-side issue occurred while creating the vacancy.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:school) { create(:school) }
        let(:source) { build(:vacancy, :external) }
        let(:school_urns) { [school].map(&:urn) }
        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: source.external_advert_url,
              expires_at: source.expires_at,
              job_title: source.job_title,
              job_advert: source.job_advert,
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
        let(:exception) { StandardError.new("Internal server error") }

        before do
          allow(Sentry).to receive(:capture_exception)
          allow(Publishers::AtsApi::CreateVacancyService).to receive(:call).and_raise(exception)
        end

        run_test! do |response|
          expect(Sentry).to have_received(:capture_exception).with(exception)
          expect(response.parsed_body).to eq({ "errors" => ["There was an internal error processing this request"] })
        end
      end
    end
  end

  path "/ats-api/v1/vacancies/{id}" do
    parameter name: "id", in: :path, type: :string, description: "The id of the vacancy"

    let(:original_publish_on) { Time.zone.today.strftime("%Y-%m-%d") }
    let!(:trust) { create(:trust) }
    let!(:school) { create(:school, school_groups: [trust]) }
    let!(:original_vacancy) do
      create(:vacancy,
             :external,
             job_title: "Languages teacher",
             organisations: [school],
             publisher_ats_api_client: client,
             other_start_date_details: "Around April",
             start_date_type: "other",
             starts_on: nil,
             is_job_share: true,
             ect_status: "ect_unsuitable",
             publish_on: original_publish_on,
             benefits_details: "Original benefits",
             visa_sponsorship_available: false,
             key_stages: %w[ks1 ks2],
             subjects: %w[English Spanish])
    end
    let(:id) { original_vacancy.id }

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

        schema "$ref" => "#/components/schemas/vacancy_response"

        it "retrieves the vacancy details" do |example|
          expect { submit_request(example.metadata) }.not_to change(Vacancy, :count)
          assert_response_matches_metadata(example.metadata)
          expect(response.parsed_body).to include(
            "id" => id,
            "public_url" => job_url(original_vacancy),
            "external_advert_url" => original_vacancy.external_advert_url,
            "publish_on" => original_vacancy.publish_on.iso8601,
            "expires_at" => original_vacancy.expires_at.iso8601(3),
            "job_title" => original_vacancy.job_title,
            "job_advert" => original_vacancy.job_advert,
            "salary" => original_vacancy.salary,
            "visa_sponsorship_available" => original_vacancy.visa_sponsorship_available,
            "external_reference" => original_vacancy.external_reference,
            "is_job_share" => original_vacancy.is_job_share,
            "ect_suitable" => original_vacancy.ect_status == "ect_suitable",
            "job_roles" => original_vacancy.job_roles,
            "working_patterns" => original_vacancy.working_patterns,
            "contract_type" => original_vacancy.contract_type,
            "phases" => original_vacancy.phases,
            "benefits_details" => original_vacancy.benefits_details,
            "starts_on" => original_vacancy.other_start_date_details,
            "key_stages" => original_vacancy.key_stages,
            "subjects" => original_vacancy.subjects,
            "schools" => { "school_urns" => [school.urn], "trust_uid" => trust.uid },
          )
        end

        context "when the vacancy is still not published", document: false do
          let(:original_publish_on) { (Time.zone.today + 1).strftime("%Y-%m-%d") }

          it "doesn't contain a public_url" do |example|
            expect { submit_request(example.metadata) }.not_to change(Vacancy, :count)
            assert_response_matches_metadata(example.metadata)

            expect(response.parsed_body).to include(
              "id" => id,
              "public_url" => nil,
            )
          end
        end
      end

      response(401, "Occurs when the provided API key is incorrect or missing.") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:vacancy) { {} }
        let(:"X-Api-Key") { "wrong-key" }

        run_test! do |response|
          expect(response.parsed_body).to eq({ "errors" => ["Invalid API key"] })
        end
      end

      response(404, "No vacancy was found with the provided ID that belongs to this client.") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }

        run_test! do |response|
          expect(response.parsed_body).to eq({ "errors" => ["The given ID does not match any vacancy for your ATS"] })
        end
      end

      response(500, "An unexpected error occurred on the server.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:exception) { StandardError.new("Internal server error") }

        before do
          allow(Sentry).to receive(:capture_exception)
          allow(Vacancy).to receive(:kept).and_raise(exception)
        end

        run_test! do |response|
          expect(Sentry).to have_received(:capture_exception).with(exception)
          expect(response.parsed_body).to eq({ "errors" => ["There was an internal error processing this request"] })
        end
      end
    end

    put("Updates an existing vacancy. The request body must include all required fields. Optional fields keep existing values if not provided.") do
      tags "Vacancies"
      consumes "application/json"
      produces "application/json"

      security [api_key: []]

      parameter name: :vacancy, in: :body, schema: { "$ref" => "#/components/schemas/vacancy_request" }

      response(200, "Indicates the vacancy was updated. Returns the updated resource data.") do
        schema "$ref" => "#/components/schemas/vacancy_response"

        let(:publish_on) { Time.zone.today.strftime("%Y-%m-%d") }
        let(:expires_at) { Time.zone.today + 7.days }
        let(:vacancy_params) do
          {
            external_advert_url: "https://www.example.com/ats-site/advertid",
            expires_at: expires_at.strftime("%Y-%m-%d"),
            job_title: "Teacher of Geography",
            job_advert: "We're looking for a dedicated Teacher of Geography",
            salary: "£12,345 to £67,890",
            visa_sponsorship_available: true,
            is_job_share: false,
            external_reference: "REF1234HYZ",
            ect_suitable: true,
            job_roles: %w[teacher],
            working_patterns: %w[full_time],
            contract_type: "permanent",
            publish_on: publish_on,
            benefits_details: "Extra benefits",
            starts_on: "2026-10-12",
            key_stages: %w[ks2],
            subjects: %w[Geography],
            phases: %w[secondary],
            schools: {
              trust_uid: original_vacancy.organisation.trust.uid,
            },
          }
        end
        let(:vacancy) { { vacancy: vacancy_params } }

        it "updates the vacancy with the given values" do |example|
          expect { submit_request(example.metadata) }.not_to change(Vacancy, :count)
          assert_response_matches_metadata(example.metadata)

          expect(response.parsed_body).to include(
            "id" => id,
            "public_url" => "http://www.example.com/jobs/teacher-of-geography",
            "external_advert_url" => "https://www.example.com/ats-site/advertid",
            "expires_at" => expires_at.in_time_zone.strftime("%Y-%m-%dT%H:%M:%S.000%:z"),
            "job_title" => "Teacher of Geography",
            "job_advert" => "We're looking for a dedicated Teacher of Geography",
            "salary" => "£12,345 to £67,890",
            "visa_sponsorship_available" => true,
            "external_reference" => "REF1234HYZ",
            "is_job_share" => false,
            "ect_suitable" => true,
            "job_roles" => %w[teacher],
            "working_patterns" => %w[full_time],
            "contract_type" => "permanent",
            "publish_on" => publish_on,
            "benefits_details" => "Extra benefits",
            "starts_on" => "2026-10-12",
            "key_stages" => %w[ks2],
            "subjects" => %w[Geography],
            "phases" => %w[secondary],
            "schools" => { "school_urns" => [], # Reassigned the vacancy to the trust central office
                           "trust_uid" => original_vacancy.trust_uid },
          )
        end

        it "enqueues UpdateGoogleIndexQueueJob with the correct job URL", document: false do |example|
          expect(UpdateGoogleIndexQueueJob).to receive(:perform_later)
          submit_request(example.metadata)
          assert_response_matches_metadata(example.metadata)
        end

        context "when not providing the optional parameters", document: false do
          let(:vacancy_params) do
            super().except(:publish_on,
                           :benefits_details,
                           :starts_on,
                           :visa_sponsorship_available,
                           :is_job_share,
                           :ect_suitable,
                           :key_stages,
                           :subjects)
          end

          it "keeps the existing values for the not provided parameters" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body).to include(
              "visa_sponsorship_available" => original_vacancy.visa_sponsorship_available,
              "is_job_share" => original_vacancy.is_job_share,
              "ect_suitable" => false,
              "publish_on" => original_publish_on,
              "benefits_details" => original_vacancy.benefits_details,
              "starts_on" => original_vacancy.other_start_date_details,
              "key_stages" => original_vacancy.key_stages,
              "subjects" => original_vacancy.subjects,
            )
          end
        end

        context "when the vacancy is not published", document: false do
          let(:publish_on) { (Time.zone.today + 3).strftime("%Y-%m-%d") }

          it "removes the public_url" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body).to include(
              "publish_on" => publish_on,
              "public_url" => nil,
            )
          end
        end
      end

      response(400, "Missing or invalid fields in the request body.") do
        schema "$ref" => "#/components/schemas/bad_request_error"

        let(:source) { build_stubbed(:vacancy, :external) }
        let(:vacancy) do
          {
            vacancy: {
              job_advert: source.job_advert,
              salary: source.salary,
              schools: { school_urns: %w[12345] },
              job_title: source.job_title,
              job_roles: source.job_roles,
              working_patterns: source.working_patterns,
              contract_type: source.contract_type,
              phases: source.phases,
            },
          }
        end

        it "list all the missing parameters" do |example|
          submit_request(example.metadata)
          assert_response_matches_metadata(example.metadata)
          expect(response.parsed_body.keys).to eq(%w[errors])
          expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
            .to contain_exactly("The property '#/vacancy' did not contain a required property of 'external_advert_url'",
                                "The property '#/vacancy' did not contain a required property of 'expires_at'",
                                "The property '#/vacancy' did not contain a required property of 'external_reference'")
        end

        context "when the request has a completely empty body", document: false do
          let(:vacancy) { nil }
          let(:empty_params) do
            ActionController::Parameters.new({ "controller" => "publishers/ats_api/v1/vacancies",
                                               "action" => "update",
                                               "id" => id })
          end

          # Explicitly override the standard parameter processing to stub "vacancy" key not being present
          before do
            allow_any_instance_of(Publishers::AtsApi::V1::VacanciesController).to receive(:params) # rubocop:disable RSpec/AnyInstance
              .and_return(empty_params)
          end

          it "lists the missing vacancy parameter" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body.keys).to eq(%w[errors])
            expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
              .to contain_exactly("The property '#/' did not contain a required property of 'vacancy'")
          end
        end

        context "when the request contains only the main vacancy parameter but no params within it", document: false do
          let(:vacancy) { { vacancy: {} } }

          it "list all the missing parameters" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body.keys).to eq(%w[errors])
            expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
              .to contain_exactly("The property '#/vacancy' did not contain a required property of 'external_advert_url'",
                                  "The property '#/vacancy' did not contain a required property of 'expires_at'",
                                  "The property '#/vacancy' did not contain a required property of 'job_title'",
                                  "The property '#/vacancy' did not contain a required property of 'job_advert'",
                                  "The property '#/vacancy' did not contain a required property of 'salary'",
                                  "The property '#/vacancy' did not contain a required property of 'external_reference'",
                                  "The property '#/vacancy' did not contain a required property of 'job_roles'",
                                  "The property '#/vacancy' did not contain a required property of 'working_patterns'",
                                  "The property '#/vacancy' did not contain a required property of 'contract_type'",
                                  "The property '#/vacancy' did not contain a required property of 'phases'",
                                  "The property '#/vacancy' did not contain a required property of 'schools'")
          end
        end

        context "when the request contains params outside the vacancy param" do
          let(:vacancy) { nil }
          let(:wrong_params) do
            ActionController::Parameters.new({ "controller" => "publishers/ats_api/v1/vacancies",
                                               "action" => "create",
                                               "expires_at" => source.expires_at,
                                               "job_advert" => source.job_advert })
          end

          # Explicitly override the standard parameter processing to stub "vacancy" key not being present
          before do
            allow_any_instance_of(Publishers::AtsApi::V1::VacanciesController).to receive(:params) # rubocop:disable RSpec/AnyInstance
              .and_return(wrong_params)
          end

          it "lists the missing vacancy parameter" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body.keys).to eq(%w[errors])
            expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
              .to contain_exactly("The property '#/' did not contain a required property of 'vacancy'")
          end
        end

        context "when the request contains enum values non defined in the schema", document: false do
          let(:vacancy_params) do
            {
              external_advert_url: "https://www.example.com/ats-site/advertid",
              expires_at: source.expires_at.strftime("%Y-%m-%d"),
              job_title: "Teacher of Geography",
              job_advert: "We're looking for a dedicated Teacher of Geography",
              salary: "£12,345 to £67,890",
              visa_sponsorship_available: true,
              is_job_share: false,
              external_reference: "REF1234HYZ",
              ect_suitable: true,
              job_roles: %w[teacher],
              working_patterns: %w[wrong_time],
              contract_type: "permanent",
              publish_on: source.publish_on,
              benefits_details: "Extra benefits",
              starts_on: "2026-10-12",
              key_stages: %w[wrong_ks],
              subjects: %w[Geography],
              phases: %w[wrong_phase],
              schools: {
                trust_uid: original_vacancy.organisation.trust.uid,
              },
            }
          end
          let(:vacancy) { { vacancy: vacancy_params } }

          it "describes the error" do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)
            expect(response.parsed_body.keys).to eq(%w[errors])
            expect(response.parsed_body.fetch("errors").map { |x| /(.+) in schema/.match(x)[1] })
              .to contain_exactly("The property '#/vacancy/key_stages/0' value \"wrong_ks\" did not match one of the following values: early_years, ks1, ks2, ks3, ks4, ks5",
                                  "The property '#/vacancy/working_patterns/0' value \"wrong_time\" did not match one of the following values: full_time, part_time",
                                  "The property '#/vacancy/phases/0' value \"wrong_phase\" did not match one of the following values: nursery, primary, secondary, sixth_form_or_college, through")
          end
        end
      end

      response(401, "Occurs when the provided API key is incorrect or missing.") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:vacancy) { {} }
        let(:"X-Api-Key") { "wrong-key" }

        run_test! do |response|
          expect(response.parsed_body).to eq({ "errors" => ["Invalid API key"] })
        end
      end

      response(404, "No vacancy was found with the provided ID that belongs to this client.") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }

        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: "https://www.example.com/ats-site/advertid",
              expires_at: "2022-01-01",
              job_title: "Teacher of Geography",
              job_advert: "We're looking for a dedicated Teacher of Geography",
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

        run_test! do |response|
          expect(response.parsed_body).to eq({ "errors" => ["The given ID does not match any vacancy for your ATS"] })
        end
      end

      response(409, "An existing vacancy with the same external reference already exists.") do
        schema "$ref" => "#/components/schemas/conflict_error"

        let!(:other_vacancy) { create(:vacancy, :external, publisher_ats_api_client: client, external_reference: "EXISTING-REF") }
        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: "https://www.example.com/ats-site/advertid",
              expires_at: "2022-01-01",
              job_title: "Teacher of Geography",
              job_advert: "We're looking for a dedicated Teacher of Geography",
              salary: "£12,345 to £67,890",
              visa_sponsorship_available: true,
              external_reference: "EXISTING-REF",
              is_job_share: true,
              job_roles: %w[teacher],
              working_patterns: %w[full_time],
              contract_type: "permanent",
              phases: %w[secondary],
              schools: {
                school_urns: [original_vacancy.organisation.urn],
              },
            },
          }
        end

        run_test! do |response|
          expect(response.parsed_body.keys).to match_array(%w[errors meta])
          expect(response.parsed_body["errors"]).to eq(["A vacancy with the provided ATS client ID and external reference already exists."])
          expect(response.parsed_body["meta"]["link"]).to end_with("/ats-api/v1/vacancies/#{other_vacancy.id}")
        end
      end

      response(422, "One or more values failed validation.") do
        schema "$ref" => "#/components/schemas/validation_error"

        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: "https://www.example.com/ats-site/advertid",
              expires_at: "2022-01-01",
              job_title: "",
              job_advert: "We're looking for a dedicated Teacher of Geography",
              salary: "£12,345 to £67,890",
              visa_sponsorship_available: true,
              external_reference: "",
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

        it "lists the failed validations" do |example|
          submit_request(example.metadata)
          assert_response_matches_metadata(example.metadata)
          expect(response.parsed_body).to eq(
            { "errors" => ["job_title: can't be blank", "external_reference: Enter an external reference", "expires_at: must be a future date", "expires_at: must be later than the publish date"] },
          )
        end
      end

      response(500, "An unexpected error occurred on the server.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:vacancy) do
          {
            vacancy: {
              external_advert_url: "https://www.example.com/ats-site/advertid",
              expires_at: "2022-01-01",
              job_title: "Teacher of Geography",
              job_advert: "We're looking for a dedicated Teacher of Geography",
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

        let(:exception) { StandardError.new("Internal server error") }

        before do
          allow(Sentry).to receive(:capture_exception)
          allow(Vacancy).to receive(:kept).and_raise(exception)
        end

        run_test! do |response|
          expect(Sentry).to have_received(:capture_exception).with(exception)
          expect(response.parsed_body).to eq({ "errors" => ["There was an internal error processing this request"] })
        end
      end
    end

    delete("Deletes a vacancy with the given ID, if it belongs to the client's ATS.") do
      tags "Vacancies"
      consumes "application/json"
      produces "application/json"

      security [api_key: []]

      response(204, "Indicates the vacancy was removed from the system.") do
        it "removes the vaancy" do |example|
          expect { submit_request(example.metadata) }.to change(PublishedVacancy.live.where(publisher_ats_api_client: client), :count).from(1).to(0)
          assert_response_matches_metadata(example.metadata)
          expect(response.parsed_body).to be_empty
        end
      end

      response(401, "Occurs when the provided API key is incorrect or missing.") do
        schema "$ref" => "#/components/schemas/unauthorized_error"

        let(:"X-Api-Key") { "wrong-key" }

        run_test! do |response|
          expect(response.parsed_body).to eq({ "errors" => ["Invalid API key"] })
        end
      end

      response(404, "No vacancy was found with the provided ID that belongs to this client.") do
        schema "$ref" => "#/components/schemas/not_found_error"

        let(:id) { "123" }

        run_test! do |response|
          expect(response.parsed_body).to eq({ "errors" => ["The given ID does not match any vacancy for your ATS"] })
        end
      end

      response(500, "An unexpected error occurred on the server.") do
        schema "$ref" => "#/components/schemas/internal_server_error"

        let(:exception) { StandardError.new("Internal server error") }

        before do
          allow(Sentry).to receive(:capture_exception)
          allow(Vacancy).to receive(:kept).and_raise(exception)
        end

        run_test! do |response|
          expect(Sentry).to have_received(:capture_exception).with(exception)
          expect(response.parsed_body).to eq({ "errors" => ["There was an internal error processing this request"] })
        end
      end
    end
  end
end
# rubocop:enable RSpec/VariableName
# rubocop:enable RSpec/ScatteredSetup
