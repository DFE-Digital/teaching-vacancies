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

RSpec.describe ImportFromVacancySourcesJob do
  before do
    stub_const("ImportFromVacancySourcesJob::SOURCES", [FakeVacancySource])
    FakeVacancySource.vacancies = vacancies_from_source
    expect(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
  end

  let(:school) { create(:school) }

  describe "#perform" do
    context "when a new valid vacancy comes through" do
      let(:vacancies_from_source) { [vacancy] }
      let(:vacancy) { build(:vacancy, :published, :external, phases: %w[secondary], organisations: [school]) }

      it "saves the vacancy" do
        expect { described_class.perform_now }.to change { Vacancy.count }.by(1)
      end
    end

    context "when a new vacancy comes through but isn't valid" do
      let(:vacancies_from_source) { [vacancy] }
      let(:vacancy) do
        build(:vacancy,
              :published,
              :external,
              phases: [],
              organisations: [school],
              job_title: "",
              safeguarding_information: "test",
              about_school: "test",
              benefits_details: "ut sit dolores.",
              contact_email: "alexa.baumbach@example.com",
              personal_statement_guidance: "Maxime blanditiis quos. Cum officia facilis. Et et quod. Dolore id ut. Id aut quia.",
              school_offer: "School Offer",
              skills_and_experience: "Quasi dolores vero molestiae et velit aut nulla dolorem odit officiis sit ea sint earum et accusantium optio illo dolorem numquam in et est quia ab consequatur aperiam aut et alias rerum fuga est impedit enim et sunt ea tempora facilis eaque voluptate ex iure voluptates necessitatibus ipsa veniam nihil.",
              slug: "mallowpond-high-school",
              expires_at: "2023-06-06T09:00:00.000+01:00",
              full_time_details: "Sapiente.",
              further_details: "details",
              how_to_apply: "Click button",
              job_advert: "Aut repellat vel. Nesciunt exercitationem et. Numquam a corrupti. Et minus hic. Perspiciatis dolor neque. Sit est nemo. Ut ex officiis. Illum et mollitia. Quia qui qui. Debitis totam odio. Consequatur eum iste. Aut ex et. Quo explicabo quae. Aut id laborum. Occaecati quod sit. Laudantium ipsum placeat. Et sed nesciunt. Ut iste maxime. Ea repudiandae rem. Qui fugit adipisci. Vero fugiat dolor. Nesciunt eum et. Molestias nulla facere. Aliquid dolore assumenda. Aut repudiandae iusto. Quia aut maxime. Consequatur voluptates facere. Facere eius asperiores. Fugiat occaecati assumenda. Maiores consequatur architecto. Perferendis sint ut. Est odio dolorem. Aliquid fugiat iusto. Eaque fugiat voluptas. Eos velit assumenda. Nesciunt minus quia. Cupiditate vero dolor. Quos temporibus consequuntur. Vel cupiditate eos. Dolore dolores repellat. Ex ipsam consequuntur. Dolores harum voluptatem. Temporibus neque quis. Vero soluta sunt. Voluptas laboriosam modi. Quod ut nostrum. Veniam voluptatem et. Explicabo necessitatibus ex. Ut architecto placeat. Neque velit et.")
      end

      it "does not save the vacancy to the Vacancies table" do
        expect { described_class.perform_now }.to change { Vacancy.count }.by(0)
      end

      it "saves the vacancy in the FailedVacancyImports table" do
        expect { described_class.perform_now }.to change { FailedImportedVacancy.count }.by(1)
      end

      it "saves the vacancy in the FailedVacancyImports with the import errors and identifiable info" do
        described_class.perform_now

        expect(FailedImportedVacancy.first.source).to eq("fake_source")
        expect(FailedImportedVacancy.first.external_reference).to eq("J3D1")
        expect(FailedImportedVacancy.first.import_errors.first).to eq("job_title:[can't be blank]")
        expect(FailedImportedVacancy.first.import_errors.last).to eq("phases:[can't be blank]")
        expect(FailedImportedVacancy.first.vacancy).to eq(
          "about_school" => "test",
          "actual_salary" => "20000",
          "application_email" => nil,
          "application_link" => nil,
          "benefits" => true,
          "benefits_details" => "ut sit dolores.",
          "completed_steps" => %w[job_location job_role education_phases job_title key_stages subjects contract_type working_patterns pay_package important_dates start_date applying_for_the_job school_visits contact_details about_the_role include_additional_documents],
          "contact_email" => "alexa.baumbach@example.com",
          "contact_number" => "01234 123456",
          "contact_number_provided" => true,
          "contract_type" => "permanent",
          "created_at" => nil,
          "earliest_start_date" => nil,
          "ect_status" => "ect_suitable",
          "enable_job_applications" => true,
          "expired_vacancy_feedback_email_sent_at" => nil,
          "expires_at" => "2023-06-06T09:00:00.000+01:00",
          "external_advert_url" => "https://example.com/jobs/123",
          "external_reference" => "J3D1",
          "external_source" => "may_the_feed_be_with_you",
          "fixed_term_contract_duration" => "6 months",
          "full_time_details" => vacancy.full_time_details,
          "further_details" => "details",
          "further_details_provided" => true,
          "geolocation" => "POINT (2.0 1.0)",
          "google_index_removed" => false,
          "hired_status" => nil,
          "how_to_apply" => "Click button",
          "id" => nil,
          "include_additional_documents" => false,
          "job_advert" => "Aut repellat vel. Nesciunt exercitationem et. Numquam a corrupti. Et minus hic. Perspiciatis dolor neque. Sit est nemo. Ut ex officiis. Illum et mollitia. Quia qui qui. Debitis totam odio. Consequatur eum iste. Aut ex et. Quo explicabo quae. Aut id laborum. Occaecati quod sit. Laudantium ipsum placeat. Et sed nesciunt. Ut iste maxime. Ea repudiandae rem. Qui fugit adipisci. Vero fugiat dolor. Nesciunt eum et. Molestias nulla facere. Aliquid dolore assumenda. Aut repudiandae iusto. Quia aut maxime. Consequatur voluptates facere. Facere eius asperiores. Fugiat occaecati assumenda. Maiores consequatur architecto. Perferendis sint ut. Est odio dolorem. Aliquid fugiat iusto. Eaque fugiat voluptas. Eos velit assumenda. Nesciunt minus quia. Cupiditate vero dolor. Quos temporibus consequuntur. Vel cupiditate eos. Dolore dolores repellat. Ex ipsam consequuntur. Dolores harum voluptatem. Temporibus neque quis. Vero soluta sunt. Voluptas laboriosam modi. Quod ut nostrum. Veniam voluptatem et. Explicabo necessitatibus ex. Ut architecto placeat. Neque velit et.",
          "job_location" => nil,
          "job_role" => "teacher",
          "job_roles" => nil,
          "job_title" => "",
          "key_stages" => [],
          "latest_start_date" => nil,
          "listed_elsewhere" => nil,
          "other_start_date_details" => nil,
          "parental_leave_cover_contract_duration" => "6 months",
          "part_time_details" => nil,
          "pay_scale" => "Main pay range 1 to Upper pay range 3, £23,719 to £39,406 per year (full time equivalent)",
          "personal_statement_guidance" => "Maxime blanditiis quos. Cum officia facilis. Et et quod. Dolore id ut. Id aut quia.",
          "phase" => nil,
          "phases" => [],
          "publish_on" => "2022-12-06",
          "publisher_id" => nil,
          "publisher_organisation_id" => nil,
          "readable_job_location" => nil,
          "readable_phases" => [],
          "receive_applications" => nil,
          "safeguarding_information" => "test",
          "safeguarding_information_provided" => true,
          "salary" => "Main pay range 1 to Upper pay range 3, £23,719 to £39,406 per year (full time equivalent)",
          "school_offer" => "School Offer",
          "school_visits" => true,
          "school_visits_details" => nil,
          "searchable_content" => nil,
          "skills_and_experience" => "Quasi dolores vero molestiae et velit aut nulla dolorem odit officiis sit ea sint earum et accusantium optio illo dolorem numquam in et est quia ab consequatur aperiam aut et alias rerum fuga est impedit enim et sunt ea tempora facilis eaque voluptate ex iure voluptates necessitatibus ipsa veniam nihil.",
          "slug" => "mallowpond-high-school",
          "start_date_type" => "specific_date",
          "starts_asap" => nil,
          "starts_on" => "2023-12-06",
          "stats_updated_at" => nil,
          "status" => "published",
          "subjects" => ["Accounting", "Art and design"],
          "updated_at" => nil,
          "working_patterns" => ["full_time"],
          "working_patterns_details" => nil,
        )
      end
    end

    context "when there is already a duplicate vacancy in the FailedImportedVacancy table" do
      let(:vacancies_from_source) { [vacancy1, vacancy2] }
      let(:vacancy1) { build(:vacancy, :published, :external, external_reference: "123", phases: [], organisations: [school], job_title: "") }
      let(:vacancy2) { build(:vacancy, :published, :external, external_reference: "123", phases: [], organisations: [school], job_title: "") }

      it "does not save the second vacancy" do
        described_class.perform_now

        expect(FailedImportedVacancy.count).to eq(1)
      end
    end

    context "when a live vacancy no longer comes through" do
      let!(:vacancy) { create(:vacancy, :published, :external, phases: %w[secondary], organisations: [school], external_source: "fake_source", external_reference: "123", updated_at: 1.hour.ago) }
      let(:vacancies_from_source) { [] }

      it "sets the vacancy to have the correct status" do
        expect { described_class.perform_now }
          .to change { vacancy.reload.status }
          .from("published").to("removed_from_external_system")
      end
    end

    context "when an expired vacancy no longer comes through" do
      let!(:vacancy) { create(:vacancy, :expired_yesterday, :external, phases: %w[secondary], organisations: [school], external_source: "fake_source", external_reference: "123", updated_at: 1.hour.ago) }
      let(:vacancies_from_source) { [] }

      it "does not change the vacancy's status" do
        expect { described_class.perform_now }.not_to(change { vacancy.reload.status })
      end
    end
  end
end
