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
  let(:expires_at) { Time.zone.today + 30.days }
  let(:publish_on) { nil }
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
      expires_at: expires_at,
      salary: "£30,000 - £40,000",
      schools: organisations,
      publisher_ats_api_client_id: publisher_ats_api_client_id,
      publish_on: publish_on,
    }
  end

  describe "#call" do
    context "when the vacancy is successfully created" do
      it "returns a success response" do
        expect(create_vacancy_service).to eq(status: :created, json: { id: PublishedVacancy.last.id })
      end

      it "creates a published vacancy with the correct external reference" do
        expect { create_vacancy_service }.to change(PublishedVacancy, :count).by(1)
        vacancy = PublishedVacancy.last
        expect(vacancy.external_reference).to eq("new-ref")
      end

      describe "'publish_on'" do
        it "defaults to the current date when not provided" do
          create_vacancy_service
          expect(PublishedVacancy.last.publish_on).to eq(Time.zone.today)
        end

        it "gets set from the parameters when provided" do
          publish_on = Time.zone.today + 1
          params[:publish_on] = publish_on
          create_vacancy_service
          expect(PublishedVacancy.last.publish_on).to eq(publish_on)
        end
      end

      describe "'is_job_share'" do
        it "defaults to false when not provided" do
          create_vacancy_service
          expect(PublishedVacancy.last.is_job_share).to be(false)
        end

        it "gets set as 'true' when provided as a boolean" do
          params[:is_job_share] = true
          create_vacancy_service
          expect(PublishedVacancy.last.is_job_share).to be(true)
        end

        it "gets set as 'true' when provided as a string" do
          params[:is_job_share] = "true"
          create_vacancy_service
          expect(PublishedVacancy.last.is_job_share).to be(true)
        end

        it "gets set as 'false' when provided as a boolean" do
          params[:is_job_share] = false
          create_vacancy_service
          expect(PublishedVacancy.last.is_job_share).to be(false)
        end

        it "gets set as 'false' when provided as a string" do
          params[:is_job_share] = "false"
          create_vacancy_service
          expect(PublishedVacancy.last.is_job_share).to be(false)
        end

        it "gets set as 'false' when any other string come" do
          params[:is_job_share] = "foobar"
          create_vacancy_service
          expect(PublishedVacancy.last.is_job_share).to be(false)
        end
      end

      describe "'visa_sponsorship_available'" do
        it "defaults to false when not provided" do
          create_vacancy_service
          expect(PublishedVacancy.last.visa_sponsorship_available).to be(false)
        end

        it "gets set as 'true' when provided as a boolean" do
          params[:visa_sponsorship_available] = true
          create_vacancy_service
          expect(PublishedVacancy.last.visa_sponsorship_available).to be(true)
        end

        it "gets set as 'true' when provided as a string" do
          params[:visa_sponsorship_available] = "true"
          create_vacancy_service
          expect(PublishedVacancy.last.visa_sponsorship_available).to be(true)
        end

        it "gets set as 'false' when provided as a boolean" do
          params[:visa_sponsorship_available] = false
          create_vacancy_service
          expect(PublishedVacancy.last.visa_sponsorship_available).to be(false)
        end

        it "gets set as 'false' when provided as a string" do
          params[:visa_sponsorship_available] = "false"
          create_vacancy_service
          expect(PublishedVacancy.last.visa_sponsorship_available).to be(false)
        end

        it "gets set as 'false' when any other string come" do
          params[:visa_sponsorship_available] = "foobar"
          create_vacancy_service
          expect(PublishedVacancy.last.visa_sponsorship_available).to be(false)
        end
      end

      describe "'ect_suitable'" do
        it "defaults ect_status to 'ect_unsuitable when 'ect_suitable' is not provided" do
          create_vacancy_service
          expect(PublishedVacancy.last.ect_status).to eq("ect_unsuitable")
        end

        it "sets 'ect_status' to 'ect_suitable' when 'ect_suitable' is true (boolean)" do
          params[:ect_suitable] = true
          create_vacancy_service
          expect(PublishedVacancy.last.ect_status).to eq("ect_suitable")
        end

        it "sets 'ect_status' to 'ect_suitable' when 'ect_suitable' is 'true' (string)" do
          params[:ect_suitable] = "true"
          create_vacancy_service
          expect(PublishedVacancy.last.ect_status).to eq("ect_suitable")
        end

        it "sets 'ect_status' to 'ect_unsuitable' when 'ect_suitable' is false (boolean)" do
          params[:ect_suitable] = false
          create_vacancy_service
          expect(PublishedVacancy.last.ect_status).to eq("ect_unsuitable")
        end

        it "sets 'ect_status' to 'ect_unsuitable' when 'ect_suitable' is 'false' (string)" do
          params[:ect_suitable] = "false"
          create_vacancy_service
          expect(PublishedVacancy.last.ect_status).to eq("ect_unsuitable")
        end

        it "sets 'ect_status' to 'ect_unsuitable' when any other string come" do
          params[:ect_suitable] = "foobar"
          create_vacancy_service
          expect(PublishedVacancy.last.ect_status).to eq("ect_unsuitable")
        end
      end

      describe "start date fields" do
        context "when starts_on is not provided" do
          it "does not set any start date fields" do
            create_vacancy_service
            expect(PublishedVacancy.last).to have_attributes(starts_on: nil,
                                                             start_date_type: nil,
                                                             other_start_date_details: nil)
          end
        end

        context "when starts_on is formatted as a date" do
          let(:starts_on) { Time.zone.tomorrow.strftime("%Y-%m-%d") }
          let(:params) { super().merge(starts_on: starts_on) }

          it "sets the specific start date to the provided date" do
            create_vacancy_service
            expect(PublishedVacancy.last).to have_attributes(starts_on: Time.zone.tomorrow,
                                                             start_date_type: "specific_date",
                                                             other_start_date_details: nil)
          end
        end

        context "when starts_on is not a formatted as a date" do
          let(:starts_on) { "September 2022" }
          let(:params) { super().merge(starts_on: starts_on) }

          it "sets the other start date details to the provided date" do
            create_vacancy_service
            expect(PublishedVacancy.last).to have_attributes(starts_on: nil,
                                                             start_date_type: "other",
                                                             other_start_date_details: starts_on)
          end
        end
      end

      describe "'expires_at'" do
        let(:raw_expires_at_query) { Arel.sql("to_char(expires_at, 'YYYY-MM-DD HH24:MI:SS')") }

        context "when parsing equivalent representations during British Summer Time (BST)" do
          # All inputs below represent the same instant: 9am UK local time (Thursday, 23 April 2026 during BST).
          # They differ only in timezone notation; the app must parse each correctly and store the same instant.
          before { travel_to(Time.zone.parse("2026-04-22T10:00:00")) }

          let(:expected_local_iso8601) { "2026-04-23T09:00:00+01:00" }
          let(:expected_utc_iso8601) { "2026-04-23T08:00:00Z" }
          let(:expected_db_timestamp) { "2026-04-23 08:00:00" }

          [
            { input: "2026-04-23T08:00:00Z", desc: "UTC notation (Z suffix)" },
            { input: "2026-04-23T08:00:00+00:00", desc: "explicit UTC offset" },
            { input: "2026-04-23T09:00:00", desc: "naive local time (no timezone)" },
            { input: "2026-04-23T09:00:00+01:00", desc: "explicit UK BST offset" },
          ].each_with_index do |spec, index|
            context "when expires_at is '#{spec[:input]}' (#{spec[:desc]})" do
              let(:vacancy_params) do
                params.merge(
                  expires_at: spec[:input],
                  external_reference: "new-ref-iso-#{index}",
                  job_title: "A job title iso #{index}",
                )
              end

              it "persists the same instant: 9am UK time (08:00 UTC) regardless of input format" do
                response = described_class.call(vacancy_params)
                vacancy = PublishedVacancy.find(response[:json][:id])
                db_expires_at = Vacancy.where(id: vacancy.id).pick(raw_expires_at_query)

                expect(db_expires_at).to eq(expected_db_timestamp)
                expect(vacancy.expires_at.iso8601).to eq(expected_local_iso8601)
                expect(vacancy.expires_at.utc.iso8601).to eq(expected_utc_iso8601)
              end
            end
          end
        end

        context "when parsing equivalent representations during Greenwich Mean Time (GMT)" do
          # All inputs below represent the same instant: 9am UK local time (Tuesday, 20 January 2026 during GMT).
          # During GMT, local UK time is UTC+00:00, so local and UTC clock times match.
          before { travel_to(Time.zone.parse("2026-01-15T10:00:00")) }

          let(:expected_local_iso8601) { "2026-01-20T09:00:00+00:00" }
          let(:expected_utc_iso8601) { "2026-01-20T09:00:00Z" }
          let(:expected_db_timestamp) { "2026-01-20 09:00:00" }

          [
            { input: "2026-01-20T09:00:00Z", desc: "UTC notation (Z suffix)" },
            { input: "2026-01-20T09:00:00+00:00", desc: "explicit UTC offset" },
            { input: "2026-01-20T09:00:00", desc: "naive local time (no timezone)" },
          ].each_with_index do |spec, index|
            context "when expires_at is '#{spec[:input]}' (#{spec[:desc]})" do
              let(:vacancy_params) do
                params.merge(
                  expires_at: spec[:input],
                  external_reference: "new-ref-iso-gmt-#{index}",
                  job_title: "A job title iso gmt #{index}",
                )
              end

              it "persists the same instant: 9am UK time (09:00 UTC) regardless of input format" do
                response = described_class.call(vacancy_params)
                vacancy = PublishedVacancy.find(response[:json][:id])
                db_expires_at = Vacancy.where(id: vacancy.id).pick(raw_expires_at_query)

                expect(db_expires_at).to eq(expected_db_timestamp)
                expect(vacancy.expires_at.iso8601).to eq(expected_local_iso8601)
                expect(vacancy.expires_at.utc.iso8601).to eq(expected_utc_iso8601)
              end
            end
          end
        end

        context "with Daylight Saving Time (DST) transitions" do
          context "when created before BST with naive datetime expiring after BST starts" do
            # This verifies cross-boundary parsing from a GMT date into a BST target date.
            # For April 10, 09:00 local UK time is 08:00 UTC, and Rails stores that instant.
            before { travel_to(Time.zone.parse("2026-03-15T10:00:00")) }

            let(:vacancy_params) do
              params.merge(
                expires_at: "2026-04-10T09:00:00",
                external_reference: "new-ref-dst-pre",
                job_title: "A job title dst pre",
              )
            end

            it "stores the April BST instant correctly even when submitted before BST begins" do
              response = described_class.call(vacancy_params)
              vacancy = PublishedVacancy.find(response[:json][:id])
              db_expires_at = Vacancy.where(id: vacancy.id).pick(raw_expires_at_query)

              expect(db_expires_at).to eq("2026-04-10 08:00:00")
              expect(vacancy.expires_at.iso8601).to eq("2026-04-10T09:00:00+01:00")
              expect(vacancy.expires_at.utc.iso8601).to eq("2026-04-10T08:00:00Z")
            end
          end

          context "when created during BST expiring after clocks go back to Greenwich Mean Time (GMT) in autumn" do
            # This verifies that a BST date expiring after the autumn DST transition is stored correctly.
            # For November 15, 09:00 local UK time is 09:00 UTC, and Rails stores that instant.
            before { travel_to(Time.zone.parse("2026-08-01T10:00:00")) }

            let(:vacancy_params) do
              params.merge(
                expires_at: "2026-11-15T09:00:00",
                external_reference: "new-ref-dst-post",
                job_title: "A job title dst post",
              )
            end

            it "stores the November date correctly even when submitted during BST" do
              response = described_class.call(vacancy_params)
              vacancy = PublishedVacancy.find(response[:json][:id])
              db_expires_at = Vacancy.where(id: vacancy.id).pick(raw_expires_at_query)

              expect(db_expires_at).to eq("2026-11-15 09:00:00")
              expect(vacancy.expires_at.iso8601).to eq("2026-11-15T09:00:00+00:00")
              expect(vacancy.expires_at.utc.iso8601).to eq("2026-11-15T09:00:00Z")
            end
          end
        end
      end

      context "when the vacancy belongs to a school" do
        it "creates a vacancy with the correct organisation" do
          create_vacancy_service
          expect(PublishedVacancy.last.organisation).to eq(school)
        end
      end

      context "when the vacancy belongs to a trust" do
        let(:trust) { create(:trust) }
        let(:organisations) { { trust_uid: trust.uid } }

        it "assigns the vacancy to the trust" do
          create_vacancy_service
          expect(PublishedVacancy.last.organisation).to eq(trust)
        end
      end

      context "when the vacancy belongs to a school within a trust" do
        let(:trust) { create(:trust, schools: [school]) }
        let(:organisations) { { trust_uid: trust.uid }.merge(school_urns) }

        it "assigns the vacancy to the school within the trust" do
          create_vacancy_service
          expect(PublishedVacancy.last.organisation).to eq(school)
        end
      end

      context "when a valid school for the trust and an invalid school are both provided" do
        let(:trust) { create(:trust, schools: [school]) }
        let(:school_urns) { { school_urns: [school.urn, 9999] } }
        let(:organisations) { { trust_uid: trust.uid }.merge(school_urns) }

        it "only assigns the vacancy to the school within the trust" do
          create_vacancy_service
          vacancy = PublishedVacancy.last
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
          vacancy = PublishedVacancy.last
          expect(vacancy.organisation).to eq(school)
          expect(vacancy.organisations).to contain_exactly(school)
        end
      end
    end

    context "when a non-deleted vacancy with the same external reference exists" do
      let(:external_reference) { "existing-ref" }
      let!(:existing_vacancy) do
        create(:vacancy, :external, external_reference:, publisher_ats_api_client_id: publisher_ats_api_client_id)
      end

      it "does not create a new vacancy" do
        expect { create_vacancy_service }.not_to change(PublishedVacancy, :count)
      end

      it "returns a conflict response" do
        expect(create_vacancy_service).to eq(
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

    context "when a deleted vacancy with the same external reference exists" do
      let(:external_reference) { "existing-ref" }
      let!(:existing_vacancy) do
        create(:vacancy, :external, :trashed, external_reference:, publisher_ats_api_client_id: publisher_ats_api_client_id)
      end

      it "creates a new published vacancy with the same external reference" do
        expect { create_vacancy_service }.to change { PublishedVacancy.kept.count }.by(1)
        vacancy = PublishedVacancy.kept.last
        expect(vacancy.external_reference).to eq(existing_vacancy.external_reference)
      end

      it "returns a success response" do
        expect(create_vacancy_service).to eq(status: :created, json: { id: PublishedVacancy.kept.last.id })
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

    context "when the school has an excluded detailed_school_type" do
      let(:excluded_school) { create(:school, detailed_school_type: "Other independent school") }
      let(:school_urns) { { school_urns: [excluded_school.urn] } }

      it "raises InvalidOrganisationError with appropriate message" do
        expect { create_vacancy_service }.to raise_error(
          Publishers::AtsApi::OrganisationFetcher::InvalidOrganisationError,
          "School type 'Other independent school' is not eligible to post vacancies",
        )
      end
    end

    context "when the vacancy is missing mandatory fields" do
      let(:job_title) { nil }
      let(:job_advert) { nil }
      let(:job_roles) { [] }
      let(:working_patterns) { [] }
      let(:expires_at) { nil }

      it "returns a validation error response" do
        expect(create_vacancy_service[:status]).to eq :unprocessable_entity
        expect(create_vacancy_service[:json][:errors]).to include(
          "job_title: can't be blank",
          "job_advert: Enter a job advert",
          "job_roles: Select a job role",
          "expires_at: Enter closing date",
          "working_patterns: Select a working pattern",
        )
      end
    end

    context "when a job title is too long" do
      let(:job_title) { "this is really a super long job title but sorry it's really really important" }

      it "returns a validation error" do
        expect(create_vacancy_service).to eq(
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
      let(:expires_at) { Date.current - 1.week }

      it "returns a validation error" do
        expect(create_vacancy_service[:status]).to eq :unprocessable_entity
        expect(create_vacancy_service[:json][:errors]).to include(
          "expires_at: must be a future date",
          "expires_at: must be later than the publish date",
        )
      end
    end

    context "when expires at is before publish_on" do
      let(:expires_at) { Date.current + 1.week }
      let(:publish_on) { Date.current + 2.weeks }

      it "returns a validation error" do
        expect(create_vacancy_service).to eq(
          {
            status: :unprocessable_entity,
            json: {
              errors: ["expires_at: must be later than the publish date"],
            },
          },
        )
      end
    end

    context "when a vacancy with the same information already exists for the organisation" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          job_title: job_title,
          expires_at: params[:expires_at],
          organisations: [school],
          salary: params[:salary],
          contract_type: params[:contract_type],
          working_patterns: params[:working_patterns],
          phases: params[:phases],
        )
      end

      it "returns a conflict response" do
        expect(create_vacancy_service).to eq(
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
        # First conflict creates a new record
        expect { described_class.call(params) }.to change(VacancyConflictAttempt, :count).by(1)

        conflict_attempt = VacancyConflictAttempt.last
        expect(conflict_attempt).to have_attributes(
          publisher_ats_api_client_id: publisher_ats_api_client_id,
          conflicting_vacancy: existing_vacancy,
          attempts_count: 1,
        )

        # More conflicts add to the count
        expect { described_class.call(params) }.not_to change(VacancyConflictAttempt, :count)

        conflict_attempt.reload
        expect(conflict_attempt.attempts_count).to eq(2)
      end
    end
  end
end
