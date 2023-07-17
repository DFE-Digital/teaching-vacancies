require "rails_helper"

RSpec.describe MyNewTermVacancySource do
  let(:api_key) { "test-api-key" }
  let(:api) { MyNewTermVacancySource.new }
  let(:successful_auth_response) { { access_token: "valid_access_token" } }
  let(:response) { double("AuthenticationResponse", code: 200, body: successful_auth_response.to_json) }
  let(:job_listings_response_body) { file_fixture("vacancy_sources/my_new_term.json").read }
  let(:job_listings_response) { double("JobListingResponse", code: 200, body: job_listings_response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "123456", phase: :primary) }

  describe "successfully authenticated requests" do
    before do
      allow(MyNewTermVacancySource)
        .to receive(:get)
        .with("#{MyNewTermVacancySource::BASE_URI}/auth/#{api_key}")
        .and_return(response)

      allow(MyNewTermVacancySource)
        .to receive(:get)
        .with(
          "#{MyNewTermVacancySource::BASE_URI}/job-listings",
          headers: { "Authorization" => "Bearer valid_access_token", "Content-Type" => "application/json" },
          query: {},
        )
        .and_return(job_listings_response)
    end

    context "with a single school vacancy" do
      let(:vacancy) { subject.first }

      let(:expected_vacancy) do
        {
          job_title: "Head of Geography",
          job_advert: "Lorem ipsum dolor sit amet",
          salary: "£24,000 - £50,000 Annually",
          job_role: "teacher",
          key_stages: %w[ks2 ks3],
          working_patterns: %w[full_time part_time],
          contract_type: "permanent",
          phases: %w[primary],
          subjects: %w[Geography],
        }
      end

      it "has the correct number of vacancies" do
        expect(subject.count).to eq(1)
      end

      it "yield a newly built vacancy the correct vacancy information" do
        expect(vacancy).not_to be_persisted
        expect(vacancy).to be_changed
      end

      it "assigns correct attributes from the feed" do
        expect(vacancy).to have_attributes(expected_vacancy)
      end

      it "assigns the vacancy to the correct school and organisation" do
        expect(vacancy.organisations.first).to eq(school1)

        expect(vacancy.external_source).to eq("my_new_term")
        expect(vacancy.external_advert_url).to eq("https://www.example.co.uk/jobs/URN/EDV-2023-MNT-12345")
        expect(vacancy.external_reference).to eq("561c8f63-c105-4142-ba14-4c345118e46b2")
      end

      it "sets important dates" do
        expect(vacancy.expires_at).to eq(Time.zone.parse("2023-02-10T23:59:00+00:00"))
        expect(vacancy.publish_on).to eq(Date.today)
      end

      describe "job roles mapping" do
        let(:job_listings_response_body) { super().gsub("teacher", source_role) }

        ["null", "", " "].each do |role|
          context "when the source role is '#{role}'" do
            let(:source_role) { role }

            it "the vacancy role is null" do
              expect(vacancy.job_role).to eq(nil)
            end
          end
        end

        %w[headteacher headteacher_principal deputy_headteacher_principal deputy_headteacher assistant_headteacher assistant_headteacher_principal].each do |role|
          context "when the source role is '#{role}'" do
            let(:source_role) { role }

            it "maps the source role to 'senior_leader' in the vacancy" do
              expect(vacancy.job_role).to eq("senior_leader")
            end
          end
        end

        %w[head_of_year_or_phase head_of_department_or_curriculum head_of_year].each do |role|
          context "when the source role is '#{role}'" do
            let(:source_role) { role }

            it "maps the source role to 'middle_leader' in the vacancy" do
              expect(vacancy.job_role).to eq("middle_leader")
            end
          end
        end

        %w[learning_support other_support science_technician].each do |role|
          context "when the source role is '#{role}'" do
            let(:source_role) { role }

            it "maps the source role to 'education_support' in the vacancy" do
              expect(vacancy.job_role).to eq("education_support")
            end
          end
        end
      end
    end
  end
end
