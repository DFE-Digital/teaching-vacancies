require "rails_helper"

RSpec.describe Publishers::AtsApi::UpdateVacancyService do
  subject(:update_vacancy_service) do
    described_class.call(vacancy, params)
  end

  let(:vacancy) do
    create(
      :vacancy,
      :external,
      external_reference: "old-ref",
      publisher_ats_api_client_id: publisher_ats_api_client_id,
      job_title: "English Teacher",
      expires_at: Date.current + 1.year,
      organisations: [school],
      ect_status: "ect_unsuitable",
      working_patterns: %w[part_time],
      other_start_date_details: "September 2022",
      start_date_type: "other",
      publish_on: publish_on,
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
  let(:expires_at) { Time.zone.today + 30.days }
  let(:publish_on) { 1.week.ago }
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
      expires_at: expires_at,
      skills_and_experience: vacancy.skills_and_experience,
      salary: vacancy.salary,
      schools: school_urns,
      publisher_ats_api_client_id: publisher_ats_api_client_id,
    }
  end

  describe "#call" do
    context "when the update is successful" do
      it "returns a success status" do
        expect(update_vacancy_service).to eq(status: :ok)
      end

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
      let(:expires_at) { nil }

      it "returns a validation error response" do
        expect(update_vacancy_service[:status]).to eq :unprocessable_entity
        expect(update_vacancy_service[:json][:errors]).to include(
          "job_title: can't be blank",
          "job_advert: Enter a job advert",
          "job_roles: Select a job role",
          "expires_at: Enter closing date",
          "working_patterns: Select a working pattern",
        )
      end
    end
  end

  context "when a job title is too long" do
    let(:job_title) { "this is really a super long job title but sorry it's really really important" }

    it "returns a validation error" do
      expect(update_vacancy_service).to eq(
        {
          status: :unprocessable_entity,
          json: {
            errors: ["job_title: must be 75 characters or fewer"],
          },
        },
      )
    end
  end

  context "when expires_at date is in the past" do
    let(:expires_at) { Date.current - 1.day }

    it "returns a validation error" do
      expect(update_vacancy_service).to eq(
        {
          status: :unprocessable_entity,
          json: {
            errors: [
              "expires_at: must be a future date",
            ],
          },
        },
      )
    end
  end

  context "when expires at is before publish_on" do
    let(:expires_at) { Date.current + 1.week }
    let(:publish_on) { Date.current + 2.weeks }

    it "returns a validation error" do
      expect(update_vacancy_service).to eq(
        {
          status: :unprocessable_entity,
          json: {
            errors: ["expires_at: must be later than the publish date"],
          },
        },
      )
    end
  end

  context "when a non-deleted vacancy with the same external reference exists" do
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

    it "tracks the conflict attempt and increments on subsequent conflicts" do
      # First conflict - creates a new record
      expect { described_class.call(vacancy, params) }.to change(VacancyConflictAttempt, :count).by(1)

      conflict_attempt = VacancyConflictAttempt.last
      expect(conflict_attempt.publisher_ats_api_client_id).to eq(publisher_ats_api_client_id)
      expect(conflict_attempt.conflicting_vacancy).to eq(existing_vacancy)
      expect(conflict_attempt.conflict_type).to eq("external_reference")
      expect(conflict_attempt.attempts_count).to eq(1)

      # Second conflict - increments the count
      expect { described_class.call(vacancy, params) }.not_to change(VacancyConflictAttempt, :count)

      conflict_attempt.reload
      expect(conflict_attempt.attempts_count).to eq(2)
    end
  end

  context "when a deleted vacancy with the same external reference exists" do
    let!(:existing_vacancy) do
      create(
        :vacancy,
        :trashed,
        :external,
        external_reference: "new-ref",
        publisher_ats_api_client_id: publisher_ats_api_client_id,
      )
    end

    it "successfully updates the vacancy external reference" do
      expect { update_vacancy_service }
        .to change(vacancy, :external_reference).from("old-ref").to(existing_vacancy.external_reference)
    end

    it "returns an ok status" do
      expect(update_vacancy_service).to eq(status: :ok)
    end
  end

  context "when a vacancy with the same information already exists for the organisation" do
    let!(:existing_vacancy) do
      create(
        :vacancy,
        job_title: "Maths Teacher",
        expires_at: "2026-01-01",
        organisations: [school],
        salary: vacancy.salary,
        contract_type: vacancy.contract_type,
        phases: vacancy.phases,
        working_patterns: working_patterns,
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
            errors: ["A vacancy with the same job title, expiry date, contract type, working patterns, phases and salary already exists for this organisation."],
            meta: { link: Rails.application.routes.url_helpers.vacancy_url(existing_vacancy.id) },
          },
        },
      )
    end

    it "tracks the conflict attempt and increments on subsequent conflicts" do
      # First conflict - creates a new record
      expect { described_class.call(vacancy, params) }.to change(VacancyConflictAttempt, :count).by(1)

      conflict_attempt = VacancyConflictAttempt.last
      expect(conflict_attempt.publisher_ats_api_client_id).to eq(publisher_ats_api_client_id)
      expect(conflict_attempt.conflicting_vacancy).to eq(existing_vacancy)
      expect(conflict_attempt.conflict_type).to eq("duplicate_content")
      expect(conflict_attempt.attempts_count).to eq(1)

      # Second conflict - increments the count
      expect { described_class.call(vacancy, params) }.not_to change(VacancyConflictAttempt, :count)

      conflict_attempt.reload
      expect(conflict_attempt.attempts_count).to eq(2)
    end
  end
end
