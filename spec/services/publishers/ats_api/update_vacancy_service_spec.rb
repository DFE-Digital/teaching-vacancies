require "rails_helper"

RSpec.describe Publishers::AtsApi::UpdateVacancyService do
  subject(:update_vacancy_service) { described_class.call(vacancy, params) }

  let(:vacancy) do
    create(
      :vacancy,
      :external,
      external_reference: "old-ref",
      publisher_ats_api_client_id: publisher_ats_api_client_id,
      job_title: "English Teacher",
      expires_at: "2025-12-31",
      organisations: [school],
      ect_status: "ect_unsuitable",
      working_patterns: %w[part_time],
      other_start_date_details: "September 2022",
      start_date_type: "other",
      starts_on: nil,
    )
  end
  let(:publisher_ats_api_client_id) { create(:publisher_ats_api_client).id }
  let(:school) { create(:school) }
  let(:school_urns) { { school_urns: [school.urn] } }
  let(:job_title) { vacancy.job_title }
  let(:job_advert) { vacancy.job_advert }
  let(:job_roles) { vacancy.job_roles }
  let(:working_patterns) { %w[full_time] }
  let(:params) do
    {
      external_reference: "new-ref",
      job_title: job_title,
      job_advert: job_advert,
      external_advert_url: vacancy.external_advert_url,
      job_roles: job_roles,
      contract_type: vacancy.contract_type,
      phases: vacancy.phases,
      working_patterns: working_patterns,
      expires_at: vacancy.expires_at,
      skills_and_experience: vacancy.skills_and_experience,
      salary: vacancy.salary,
      schools: school_urns,
      publisher_ats_api_client_id: publisher_ats_api_client_id,
    }
  end

  describe "#call" do
    context "when the update is successful" do
      it "updates the attributes that differ from the original vacancy" do
        expect { update_vacancy_service }
          .to change { vacancy.reload.external_reference }.from("old-ref").to("new-ref")
          .and change { vacancy.reload.working_patterns }.from(%w[part_time]).to(%w[full_time])
      end

      it "keeps the existing value for optional attributes not provided" do
        expect { update_vacancy_service }
          .to not_change { vacancy.reload.ect_status }.from("ect_unsuitable")
          .and not_change { vacancy.reload.other_start_date_details }.from("September 2022")
          .and not_change { vacancy.reload.start_date_type }.from("other")
          .and not_change { vacancy.reload.starts_on }.from(nil)
      end

      context "when the job title is updated" do
        let(:job_title) { "Maths Teacher" }

        it "updates the vacancy job title and the slug" do
          expect { update_vacancy_service }.to change { vacancy.reload.job_title }
                                           .from("English Teacher").to("Maths Teacher")
                                           .and change { vacancy.reload.slug }
                                           .from("english-teacher").to("maths-teacher")
        end
      end

      describe "start date fields" do
        context "when starts_on is not provided" do
          it "keeps the existing start date fields" do
            update_vacancy_service
            expect(vacancy.reload).to have_attributes(other_start_date_details: "September 2022",
                                                      start_date_type: "other",
                                                      starts_on: nil)
          end
        end

        context "when starts_on is formatted as a date" do
          let(:starts_on) { Time.zone.tomorrow.strftime("%Y-%m-%d") }
          let(:params) { super().merge(starts_on: starts_on) }

          it "sets the specific start date to the provided date" do
            update_vacancy_service
            expect(vacancy.reload).to have_attributes(starts_on: Time.zone.tomorrow,
                                                      start_date_type: "specific_date",
                                                      other_start_date_details: nil)
          end
        end

        context "when starts_on is not a formatted as a date" do
          let(:starts_on) { "September 2022" }
          let(:params) { super().merge(starts_on: starts_on) }

          it "sets the other start date details to the provided date" do
            update_vacancy_service
            expect(vacancy.reload).to have_attributes(starts_on: nil,
                                                      start_date_type: "other",
                                                      other_start_date_details: starts_on)
          end
        end
      end

      describe "'ect_status' updates" do
        context "when providing a new value" do
          let(:params) { super().merge(ect_suitable: true) }

          it "updates the value" do
            update_vacancy_service
            expect(vacancy.reload.ect_status).to eq("ect_suitable")
          end
        end

        context "when the given value matches the existing status" do
          let(:params) { super().merge(ect_suitable: false) }

          it "keeps the existing value" do
            update_vacancy_service
            expect(vacancy.reload.ect_status).to eq("ect_unsuitable")
          end
        end

        context "when not providing a value" do
          let(:params) { super().except(:ect_suitable) }

          it "keeps the existing value" do
            update_vacancy_service
            expect(vacancy.reload.ect_status).to eq("ect_unsuitable")
          end
        end
      end
    end

    context "when organisations are invalid" do
      let(:school_urns) { { school_urns: [9999] } }

      it "raises Publishers::AtsApi::CreateVacancyService::InvalidOrganisationError" do
        expect { update_vacancy_service }.to raise_error(
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

      it "returns a validation error response" do
        expect(update_vacancy_service).to eq(
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
          },
        )
      end
    end
  end

  context "when a vacancy with the same external reference exists" do
    let!(:existing_vacancy) do
      create(
        :vacancy,
        :external,
        external_reference: "new-ref",
        publisher_ats_api_client_id: publisher_ats_api_client_id,
      )
    end

    it "returns a conflict response" do
      expect(update_vacancy_service).to eq(
        {
          status: :conflict,
          json: {
            errors: ["A vacancy with the provided ATS client ID and external reference already exists."],
            meta: { link: Rails.application.routes.url_helpers.vacancy_url(existing_vacancy.id) },
          },
        },
      )
    end
  end

  context "when a vacancy with the same job_title, expired_at, and organisations exists" do
    let!(:existing_vacancy) do
      create(
        :vacancy,
        job_title: "Maths Teacher",
        expires_at: "2026-01-01",
        organisations: [school],
      )
    end

    let(:params) do
      {
        external_reference: "new-ref",
        job_title: "Maths Teacher",
        job_advert: job_advert,
        external_advert_url: vacancy.external_advert_url,
        job_roles: job_roles,
        contract_type: vacancy.contract_type,
        phases: vacancy.phases,
        working_patterns: working_patterns,
        expires_at: "2026-01-01",
        skills_and_experience: vacancy.skills_and_experience,
        salary: vacancy.salary,
        schools: school_urns,
        publisher_ats_api_client_id: publisher_ats_api_client_id,
      }
    end

    it "returns a conflict response" do
      expect(update_vacancy_service).to eq(
        {
          status: :conflict,
          json: {
            errors: ["A vacancy with the same job title, expiry date, and organisation already exists."],
            meta: { link: Rails.application.routes.url_helpers.vacancy_url(existing_vacancy.id) },
          },
        },
      )
    end
  end
end
