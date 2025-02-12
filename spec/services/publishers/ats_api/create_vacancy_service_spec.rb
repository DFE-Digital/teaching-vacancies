require "rails_helper"

RSpec.describe Publishers::AtsApi::CreateVacancyService do
  subject(:create_vacancy_service) { described_class.call(params) }

  let(:school) { create(:school) }
  let(:publisher_ats_api_client_id) { create(:publisher_ats_api_client).id }
  let(:external_reference) { "new-ref" }
  let(:organisations) { school_urns }
  let(:school_urns) { { school_urns: [school.urn] } }
  let(:job_title) { "A job title" }
  let(:job_advert) { "A job advert" }
  let(:job_roles) { %w[teacher] }
  let(:working_patterns) { %w[full_time] }
  let(:params) do
    {
      external_reference: external_reference,
      job_title: job_title,
      job_advert: job_advert,
      external_advert_url: "https://example.com",
      job_roles: job_roles,
      contract_type: "fixed_term",
      phases: %w[primary],
      working_patterns: working_patterns,
      expires_at: Time.zone.today + 30,
      skills_and_experience: "Expert in teaching",
      salary: "£30,000 - £40,000",
      schools: organisations,
      publisher_ats_api_client_id: publisher_ats_api_client_id,
    }
  end

  describe "#call" do
    context "when the vacancy is successfully created" do
      it "returns a success response" do
        expect(create_vacancy_service).to eq(status: :created, json: { id: Vacancy.last.id })
      end

      it "creates a vacancy with the correct external reference" do
        create_vacancy_service
        expect(Vacancy.last.external_reference).to eq("new-ref")
      end

      context "when the vacancy belongs to a school" do
        it "creates a vacancy with the correct organisation" do
          create_vacancy_service
          expect(Vacancy.last.organisation).to eq(school)
        end
      end

      context "when the vacancy belongs to a trust" do
        let(:trust) { create(:trust) }
        let(:organisations) { { trust_uid: trust.uid } }

        it "assigns the vacancy to the trust" do
          create_vacancy_service
          expect(Vacancy.last.organisation).to eq(trust)
        end
      end

      context "when the vacancy belongs to a school within a trust" do
        let(:trust) { create(:trust, schools: [school]) }
        let(:organisations) { { trust_uid: trust.uid }.merge(school_urns) }

        it "assigns the vacancy to the school within the trust" do
          create_vacancy_service
          expect(Vacancy.last.organisation).to eq(school)
        end
      end

      context "when a valid school for the trust and an invalid school are both provided" do
        let(:trust) { create(:trust, schools: [school]) }
        let(:school_urns) { { school_urns: [school.urn, 9999] } }
        let(:organisations) { { trust_uid: trust.uid }.merge(school_urns) }

        it "only assigns the vacancy to the school within the trust" do
          create_vacancy_service
          vacancy = Vacancy.last
          expect(vacancy.organisation).to eq(school)
          expect(vacancy.organisations).to contain_exactly(school)
        end
      end

      context "when a valid school for the trust and school not belonging to the trust are both provided" do
        let(:trust) { create(:trust, schools: [school]) }
        let(:non_trust_school) { create(:school) }
        let(:school_urns) { { school_urns: [school.urn, non_trust_school.urn] } }
        let(:organisations) { { trust_uid: trust.uid }.merge(school_urns) }

        it "only assigns the vacancy to the school within the trust" do
          create_vacancy_service
          vacancy = Vacancy.last
          expect(vacancy.organisation).to eq(school)
          expect(vacancy.organisations).to contain_exactly(school)
        end
      end
    end

    context "when a vacancy with the same external reference exists" do
      let(:external_reference) { "existing-ref" }
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          external_reference: "existing-ref",
          publisher_ats_api_client_id: publisher_ats_api_client_id,
        )
      end

      let(:expected_response) do
        {
          status: :conflict,
          json: {
            error: "A vacancy with the provided data already exists",
            link: Rails.application.routes.url_helpers.vacancy_url(existing_vacancy),
          },
        }
      end

      it "returns a conflict response" do
        expect(create_vacancy_service).to eq(expected_response)
      end
    end

    context "when the given school does not exist" do
      let(:school_urns) { { school_urns: [9999] } }

      it "raises InvalidOrganisationError" do
        expect { create_vacancy_service }.to raise_error(
          Publishers::AtsApi::OrganisationFetcher::InvalidOrganisationError,
          "No valid organisations found",
        )
      end
    end

    context "when given school does not belong to the given trust" do
      let(:trust) { create(:trust, schools: [school]) }
      let(:school_urns) { { school_urns: [9999] } }
      let(:organisations) { { trust_uid: trust.uid }.merge(school_urns) }

      it "raises InvalidOrganisationError" do
        expect { create_vacancy_service }.to raise_error(
          Publishers::AtsApi::OrganisationFetcher::InvalidOrganisationError,
          "No valid organisations found",
        )
      end
    end

    context "when the vacancy fails validation" do
      let(:job_title) { nil }
      let(:job_advert) { nil }
      let(:job_roles) { [] }
      let(:working_patterns) { [] }

      let(:expected_response) do
        {
          status: :unprocessable_entity,
          json: {
            errors: [
              "job_title: can't be blank",
              "job_advert: Enter a job advert",
              "job_roles: Select a job role",
              "working_patterns: Select a working pattern",
            ],
          },
        }
      end

      it "returns a validation error response" do
        expect(create_vacancy_service).to eq(expected_response)
      end
    end

    context "when a vacancy with the same job_title, expired_at, and organisations exists" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          job_title: job_title,
          expires_at: params[:expires_at],
          organisations: [school],
        )
      end

      let(:expected_response) do
        {
          status: :conflict,
          json: {
            error: "A vacancy with the provided data already exists",
            link: Rails.application.routes.url_helpers.vacancy_url(existing_vacancy),
          },
        }
      end

      it "returns a conflict response" do
        expect(create_vacancy_service).to eq(expected_response)
      end
    end
  end
end
