require "rails_helper"

RSpec.describe VacancySource::Source::Ventrus do
  let(:response_body) { file_fixture("vacancy_sources/ventrus.xml").read }
  let(:response) { double("VentrusHttpResponse", success?: true, body: response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "Ventrus", uid: "4243", schools: schools) }
  let(:schools) { [school1] }

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:job_role) { "teaching_assistant" }

    let(:expected_vacancy) do
      {
        job_title: "Teaching Assistant",
        job_advert: "<p>This is a random advert text <br> with HTML</p>",
        salary: "£21,575 - £22,369",
        job_role: job_role,
        key_stages: ["ks2"],
        working_patterns: %w[part_time],
        contract_type: "permanent",
        phases: %w[secondary],
      }
    end

    before do
      expect(HTTParty).to receive(:get).with("http://example.com/feed.xml").and_return(response)
    end

    it "has the correct number of vacancies" do
      expect(subject.count).to eq(1)
    end

    it "yields vacancies with correct attributes" do
      expect { |b| subject.each(&b) }.to yield_with_args(an_instance_of(Vacancy))
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

      expect(vacancy.external_source).to eq("ventrus")
      expect(vacancy.external_advert_url).to eq("http://testurl.com")
      expect(vacancy.external_reference).to eq("915213")

      expect(vacancy.organisations).to eq(schools)
    end

    context "when job role is different from accepted values" do
      let(:response_body) { super().gsub("teaching_assistant", job_role) }

      %w[headteacher headteacher_principal deputy_headteacher_principal deputy_headteacher assistant_headteacher assistant_headteacher_principal].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to 'senior_leader' in the vacancy" do
            expect(vacancy.job_role).to eq("senior_leader")
          end
        end
      end

      %w[head_of_year_or_phase head_of_department_or_curriculum head_of_year].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to 'middle_leader' in the vacancy" do
            expect(vacancy.job_role).to eq("middle_leader")
          end
        end
      end

      %w[learning_support other_support science_technician].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to 'education_support' in the vacancy" do
            expect(vacancy.job_role).to eq("education_support")
          end
        end
      end
    end

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phases: %w[primary],
          external_source: "ventrus",
          external_reference: "915213",
          organisations: schools,
          job_title: "Out of date",
        )
      end

      it "yields the existing vacancy with updated information" do
        expect(vacancy.id).to eq(existing_vacancy.id)
        expect(vacancy).to be_persisted
        expect(vacancy).to be_changed

        expect(vacancy.job_title).to eq("Teaching Assistant")
      end
    end

    context "when multiple school" do
      let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:schools) { [school1, school2] }

      it "assigns the vacancy job location to the central trust" do
        expect(vacancy.readable_job_location).to eq(school1.name)
      end
    end
  end
end
