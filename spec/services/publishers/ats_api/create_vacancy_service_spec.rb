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

      it "creates a published vacancy with the correct external reference" do
        expect { create_vacancy_service }.to change(Vacancy, :count).by(1)
        vacancy = Vacancy.last
        expect(vacancy.external_reference).to eq("new-ref")
        expect(vacancy.status).to eq("published")
      end

      describe "'publish_on'" do
        it "defaults to the current date when not provided" do
          create_vacancy_service
          expect(Vacancy.last.publish_on).to eq(Time.zone.today)
        end

        it "gets set from the parameters when provided" do
          publish_on = Time.zone.today + 1
          params[:publish_on] = publish_on
          create_vacancy_service
          expect(Vacancy.last.publish_on).to eq(publish_on)
        end
      end

      describe "'is_job_share'" do
        it "defaults to false when not provided" do
          create_vacancy_service
          expect(Vacancy.last.is_job_share).to be(false)
        end

        context "when provided" do
          it "gets set as 'true' when provided as a boolean" do
            params[:is_job_share] = true
            create_vacancy_service
            expect(Vacancy.last.is_job_share).to be(true)
          end

          it "gets set as 'true' when provided as a string" do
            params[:is_job_share] = "true"
            create_vacancy_service
            expect(Vacancy.last.is_job_share).to be(true)
          end

          it "gets set as 'false' when provided as a boolean" do
            params[:is_job_share] = false
            create_vacancy_service
            expect(Vacancy.last.is_job_share).to be(false)
          end

          it "gets set as 'false' when provided as a string" do
            params[:is_job_share] = "false"
            create_vacancy_service
            expect(Vacancy.last.is_job_share).to be(false)
          end

          it "gets set as 'false' when any other string come" do
            params[:is_job_share] = "foobar"
            create_vacancy_service
            expect(Vacancy.last.is_job_share).to be(false)
          end
        end
      end

      describe "'visa_sponsorship_available'" do
        it "defaults to false when not provided" do
          create_vacancy_service
          expect(Vacancy.last.visa_sponsorship_available).to be(false)
        end

        context "when provided" do
          it "gets set as 'true' when provided as a boolean" do
            params[:visa_sponsorship_available] = true
            create_vacancy_service
            expect(Vacancy.last.visa_sponsorship_available).to be(true)
          end

          it "gets set as 'true' when provided as a string" do
            params[:visa_sponsorship_available] = "true"
            create_vacancy_service
            expect(Vacancy.last.visa_sponsorship_available).to be(true)
          end

          it "gets set as 'false' when provided as a boolean" do
            params[:visa_sponsorship_available] = false
            create_vacancy_service
            expect(Vacancy.last.visa_sponsorship_available).to be(false)
          end

          it "gets set as 'false' when provided as a string" do
            params[:visa_sponsorship_available] = "false"
            create_vacancy_service
            expect(Vacancy.last.visa_sponsorship_available).to be(false)
          end

          it "gets set as 'false' when any other string come" do
            params[:visa_sponsorship_available] = "foobar"
            create_vacancy_service
            expect(Vacancy.last.visa_sponsorship_available).to be(false)
          end
        end
      end

      describe "'ect_suitable'" do
        it "defaults ect_status to 'ect_unsuitable when not provided" do
          create_vacancy_service
          expect(Vacancy.last.ect_status).to eq("ect_unsuitable")
        end

        context "when provided" do
          it "sets 'ect_status' to 'ect_suitable' when provided as a boolean" do
            params[:ect_suitable] = true
            create_vacancy_service
            expect(Vacancy.last.ect_status).to eq("ect_suitable")
          end

          it "sets 'ect_status' to 'ect_suitable' when provided as a string" do
            params[:ect_suitable] = "true"
            create_vacancy_service
            expect(Vacancy.last.ect_status).to eq("ect_suitable")
          end

          it "sets 'ect_status' to 'ect_unsuitable' when provided as a boolean" do
            params[:ect_suitable] = false
            create_vacancy_service
            expect(Vacancy.last.ect_status).to eq("ect_unsuitable")
          end

          it "sets 'ect_status' to 'ect_unsuitable' when provided as a string" do
            params[:ect_suitable] = "false"
            create_vacancy_service
            expect(Vacancy.last.ect_status).to eq("ect_unsuitable")
          end

          it "sets 'ect_status' to 'ect_unsuitable' when any other string come" do
            params[:ect_suitable] = "foobar"
            create_vacancy_service
            expect(Vacancy.last.ect_status).to eq("ect_unsuitable")
          end
        end
      end

      describe "start date fields" do
        context "when starts_on is not provided" do
          it "does not set any start date fields" do
            create_vacancy_service
            expect(Vacancy.last).to have_attributes(starts_on: nil,
                                                    start_date_type: nil,
                                                    other_start_date_details: nil)
          end
        end

        context "when starts_on is formatted as a date" do
          let(:starts_on) { Time.zone.tomorrow.strftime("%Y-%m-%d") }
          let(:params) { super().merge(starts_on: starts_on) }

          it "sets the specific start date to the provided date" do
            create_vacancy_service
            expect(Vacancy.last).to have_attributes(starts_on: Time.zone.tomorrow,
                                                    start_date_type: "specific_date",
                                                    other_start_date_details: nil)
          end
        end

        context "when starts_on is not a formatted as a date" do
          let(:starts_on) { "September 2022" }
          let(:params) { super().merge(starts_on: starts_on) }

          it "sets the other start date details to the provided date" do
            create_vacancy_service
            expect(Vacancy.last).to have_attributes(starts_on: nil,
                                                    start_date_type: "other",
                                                    other_start_date_details: starts_on)
          end
        end
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

      it "returns a validation error response" do
        expect(create_vacancy_service).to eq(
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

    context "when a vacancy with the same job_title, expired_at, and organisations exists" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          job_title: job_title,
          expires_at: params[:expires_at],
          organisations: [school],
        )
      end

      it "returns a conflict response" do
        expect(create_vacancy_service).to eq(
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
end
