require "rails_helper"

class FakeVacancySource
  cattr_writer :vacancies

  def self.source_name
    "fake_source"
  end

  def each(...)
    @@vacancies.each(...)
  end
end

RSpec.describe ImportFromVacancySourceJob do
  before do
    FakeVacancySource.vacancies = vacancies_from_source
  end

  subject(:import_from_vacancy_source_job) { described_class.perform_now(FakeVacancySource) }

  let(:school) { create(:school) }

  describe "#perform" do
    context "when the integrations are disabled", :disable_integrations do
      let(:vacancies_from_source) { [] }

      it "does not run the import for the vacancy source class" do
        expect(FakeVacancySource).not_to receive(:new)
        described_class.perform_now(FakeVacancySource)
      end
    end

    context "when a new valid vacancy comes through" do
      let(:vacancies_from_source) { [vacancy] }
      let(:vacancy) do
        build(:vacancy, :external, :secondary, job_roles: ["teaching_assistant"], organisations: [school])
      end

      it "saves the vacancy" do
        expect { import_from_vacancy_source_job }.to change { Vacancy.count }.by(1)
        expect(Vacancy.last).to have_attributes(
          id: vacancy.id,
          phases: %w[secondary],
          organisations: [school],
          job_roles: ["teaching_assistant"],
        )
      end
    end

    context "when the vacancy has already been imported" do
      let(:vacancies_from_source) { [vacancy] }
      let(:vacancy) do
        build(:vacancy, :external, :secondary, job_roles: ["teaching_assistant"], organisations: [school], external_source: "fake_source")
      end

      before { described_class.perform_now(FakeVacancySource) }

      it "does not attempt to save the vacancy again" do
        expect(vacancy).not_to receive(:save)
        described_class.perform_now(FakeVacancySource)
      end
    end

    context "when a new vacancy comes through but isn't valid" do
      let(:vacancies_from_source) { [vacancy] }
      let(:contact_email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
      let(:vacancy) do
        build(:vacancy,
              :external,
              phases: [],
              enable_job_applications: true,
              organisations: [school],
              job_title: "",
              external_reference: "invalid_vac_ref",
              about_school: "test",
              benefits_details: "ut sit dolores.",
              contact_email: contact_email,
              school_offer: "School Offer",
              skills_and_experience: "Quasi dolores vero molestiae et velit aut nulla dolorem odit officiis sit ea sint earum et accusantium optio illo dolorem numquam in et est quia ab consequatur aperiam aut et alias rerum fuga est impedit enim et sunt ea tempora facilis eaque voluptate ex iure voluptates necessitatibus ipsa veniam nihil.",
              slug: "mallowpond-high-school",
              expires_at: "2023-06-06T09:00:00.000+01:00",
              working_patterns_details: nil,
              further_details: "details",
              job_advert: "Aut repellat vel. Nesciunt exercitationem et. Numquam a corrupti. Et minus hic. Perspiciatis dolor neque. Sit est nemo. Ut ex officiis. Illum et mollitia. Quia qui qui. Debitis totam odio. Consequatur eum iste. Aut ex et. Quo explicabo quae. Aut id laborum. Occaecati quod sit. Laudantium ipsum placeat. Et sed nesciunt. Ut iste maxime. Ea repudiandae rem. Qui fugit adipisci. Vero fugiat dolor. Nesciunt eum et. Molestias nulla facere. Aliquid dolore assumenda. Aut repudiandae iusto. Quia aut maxime. Consequatur voluptates facere. Facere eius asperiores. Fugiat occaecati assumenda. Maiores consequatur architecto. Perferendis sint ut. Est odio dolorem. Aliquid fugiat iusto. Eaque fugiat voluptas. Eos velit assumenda. Nesciunt minus quia. Cupiditate vero dolor. Quos temporibus consequuntur. Vel cupiditate eos. Dolore dolores repellat. Ex ipsam consequuntur. Dolores harum voluptatem. Temporibus neque quis. Vero soluta sunt. Voluptas laboriosam modi. Quod ut nostrum. Veniam voluptatem et. Explicabo necessitatibus ex. Ut architecto placeat. Neque velit et.",
              visa_sponsorship_available: false,
              flexi_working: "Debitis id voluptate cumque iusto quod ut libero facere repellendus est perspiciatis rem labore voluptatibus",
              is_job_share: true)
      end

      it "does not save the vacancy to the Vacancies table" do
        expect { import_from_vacancy_source_job }.to change { Vacancy.count }.by(0)
      end

      it "saves the vacancy in the FailedVacancyImports table" do
        expect { import_from_vacancy_source_job }.to change { FailedImportedVacancy.count }.by(1)
      end

      it "saves the vacancy in the FailedVacancyImports with the import errors and identifiable info" do
        import_from_vacancy_source_job

        expect(FailedImportedVacancy.first.source).to eq("fake_source")
        expect(FailedImportedVacancy.first.external_reference).to eq("invalid_vac_ref")
        expect(FailedImportedVacancy.first.import_errors).to include("job_title:[can't be blank]")
        expect(FailedImportedVacancy.first.import_errors).to include("phases:[can't be blank]")
        expect(FailedImportedVacancy.first.vacancy).to eq(
          "about_school" => "test",
          "actual_salary" => "",
          "anonymise_applications" => false,
          "application_email" => nil,
          "application_link" => nil,
          "benefits" => true,
          "benefits_details" => "ut sit dolores.",
          "completed_steps" => %w[job_location job_role education_phases job_title key_stages contract_type working_patterns pay_package important_dates start_date applying_for_the_job school_visits contact_details about_the_role include_additional_documents],
          "contact_email" => contact_email,
          "contact_number" => "01234 123456",
          "contact_number_provided" => true,
          "contract_type" => "permanent",
          "created_at" => nil,
          "discarded_at" => nil,
          "earliest_start_date" => nil,
          "ect_status" => "ect_suitable",
          "enable_job_applications" => true,
          "extension_reason" => nil,
          "expired_vacancy_feedback_email_sent_at" => nil,
          "expires_at" => "2023-06-06T09:00:00.000+01:00",
          "external_advert_url" => "https://example.com/jobs/123",
          "external_reference" => "invalid_vac_ref",
          "external_source" => "may_the_feed_be_with_you",
          "fixed_term_contract_duration" => "",
          "flexi_working" => "Debitis id voluptate cumque iusto quod ut libero facere repellendus est perspiciatis rem labore voluptatibus",
          "full_time_details" => nil,
          "further_details" => "details",
          "further_details_provided" => true,
          "geolocation" => "POINT (2.0 1.0)",
          "google_index_removed" => false,
          "hired_status" => nil,
          "id" => nil,
          "include_additional_documents" => false,
          "job_advert" => "Aut repellat vel. Nesciunt exercitationem et. Numquam a corrupti. Et minus hic. Perspiciatis dolor neque. Sit est nemo. Ut ex officiis. Illum et mollitia. Quia qui qui. Debitis totam odio. Consequatur eum iste. Aut ex et. Quo explicabo quae. Aut id laborum. Occaecati quod sit. Laudantium ipsum placeat. Et sed nesciunt. Ut iste maxime. Ea repudiandae rem. Qui fugit adipisci. Vero fugiat dolor. Nesciunt eum et. Molestias nulla facere. Aliquid dolore assumenda. Aut repudiandae iusto. Quia aut maxime. Consequatur voluptates facere. Facere eius asperiores. Fugiat occaecati assumenda. Maiores consequatur architecto. Perferendis sint ut. Est odio dolorem. Aliquid fugiat iusto. Eaque fugiat voluptas. Eos velit assumenda. Nesciunt minus quia. Cupiditate vero dolor. Quos temporibus consequuntur. Vel cupiditate eos. Dolore dolores repellat. Ex ipsam consequuntur. Dolores harum voluptatem. Temporibus neque quis. Vero soluta sunt. Voluptas laboriosam modi. Quod ut nostrum. Veniam voluptatem et. Explicabo necessitatibus ex. Ut architecto placeat. Neque velit et.",
          "job_location" => nil,
          "job_roles" => ["teacher"],
          "job_title" => "",
          "key_stages" => [],
          "latest_start_date" => nil,
          "listed_elsewhere" => nil,
          "other_extension_reason_details" => nil,
          "other_start_date_details" => nil,
          "parental_leave_cover_contract_duration" => nil,
          "part_time_details" => nil,
          "pay_scale" => "Main pay range 1 to Upper pay range 3, £23,719 to £39,406 per year (full time equivalent)",
          "phases" => [],
          "publish_on" => Date.today.strftime("%Y-%m-%d"),
          "publisher_id" => nil,
          "publisher_ats_api_client_id" => nil,
          "publisher_organisation_id" => nil,
          "readable_job_location" => nil,
          "readable_phases" => [],
          "receive_applications" => nil,
          "religion_type" => nil,
          "salary" => "Main pay range 1 to Upper pay range 3, £23,719 to £39,406 per year (full time equivalent)",
          "school_offer" => "School Offer",
          "school_visits" => true,
          "searchable_content" => nil,
          "skills_and_experience" => "Quasi dolores vero molestiae et velit aut nulla dolorem odit officiis sit ea sint earum et accusantium optio illo dolorem numquam in et est quia ab consequatur aperiam aut et alias rerum fuga est impedit enim et sunt ea tempora facilis eaque voluptate ex iure voluptates necessitatibus ipsa veniam nihil.",
          "slug" => "mallowpond-high-school",
          "start_date_type" => "specific_date",
          "starts_asap" => nil,
          "starts_on" => (Date.today + 1.year).strftime("%Y-%m-%d"),
          "stats_updated_at" => nil,
          "subjects" => [],
          "updated_at" => nil,
          "working_patterns" => ["full_time"],
          "working_patterns_details" => nil,
          "visa_sponsorship_available" => false,
          "is_parental_leave_cover" => nil,
          "is_job_share" => true,
          "hourly_rate" => "£25 per hour",
          "flexi_working_details_provided" => true,
        )
      end

      it "does not save the vacancy if it has errors attached to the vacancy" do
        vacancy.errors.add(:base, "blah")
        import_from_vacancy_source_job

        expect(vacancy).to_not be_valid
        expect(Vacancy.count).to eq(0)
        expect(FailedImportedVacancy.count).to eq(1)
        expect(FailedImportedVacancy.first.import_errors).to eq(["base:[blah]"])
      end
    end

    context "when there is already a duplicate vacancy in the FailedImportedVacancy table" do
      let(:vacancies_from_source) { [vacancy1, vacancy2] }
      let(:vacancy1) { build(:vacancy, :external, external_reference: "123", phases: [], organisations: [school], job_title: "") }
      let(:vacancy2) { build(:vacancy, :external, external_reference: "123", phases: [], organisations: [school], job_title: "") }

      it "does not save the second vacancy" do
        import_from_vacancy_source_job

        expect(FailedImportedVacancy.count).to eq(1)
      end
    end

    context "when a live vacancy no longer comes through" do
      before { create(:vacancy, :external, :secondary, organisations: [school], external_source: "fake_source", external_reference: "123", updated_at: 1.hour.ago) }

      let(:vacancies_from_source) { [] }

      it "discards the vacancy" do
        expect { import_from_vacancy_source_job }
          .to change { Vacancy.kept.count }.by(-1)
      end
    end
  end
end
