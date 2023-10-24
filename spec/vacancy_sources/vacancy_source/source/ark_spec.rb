require "rails_helper"

RSpec.describe VacancySource::Source::Ark do
  let(:response_body) { file_fixture("vacancy_sources/ark.xml").read }
  let(:response) { double("ArkHttpResponse", success?: true, body: response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "Ark", uid: "2157", schools: schools) }
  let(:schools) { [school1] }

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:job_role) { "teaching_assistant" }

    let(:expected_vacancy) do
      {
        job_title: "Tutor Fellow (Primary or Secondary)",
        job_advert: "A one year programme that prepares you to enter teacher training, in primary or secondary.",
        salary: "From £24,454",
        job_roles: [job_role],
        key_stages: [],
        working_patterns: %w[full_time],
        contract_type: "fixed_term",
        phases: %w[through],
        visa_sponsorship_available: nil,
        expires_at: Time.zone.parse("2023-10-12T12:00:00"),
        publish_on: Date.parse("2021-03-09"),
      }
    end

    before do
      expect(HTTParty).to receive(:get).with(VacancySource::Source::Ark::FEED_URL).and_return(response)
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

      expect(vacancy.external_source).to eq("ark")
      expect(vacancy.external_advert_url).to eq("https://testurl.com/ApplicationForm.aspx?enc=mEgrBL4XQK0==")
      expect(vacancy.external_reference).to eq("Solomon-1143")

      expect(vacancy.organisations).to eq(schools)
    end

    describe "start date mapping" do
      let(:fixture_date) { "2023-05-20" }

      context "when the start date contains a specific date" do
        it "stores the specific start date" do
          expect(vacancy.starts_on.to_s).to eq "2023-05-20"
          expect(vacancy.start_date_type).to eq "specific_date"
        end
      end

      context "when the start date is not present" do
        let(:response_body) { super().gsub(fixture_date, "") }

        it "doesn't store a start date" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.start_date_type).to eq nil
        end
      end

      context "when the start date is a date with extra data" do
        let(:response_body) { super().gsub(fixture_date, "2022-11-21 or later") }

        it "stores it as other start date details" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.other_start_date_details).to eq("2022-11-21 or later")
          expect(vacancy.start_date_type).to eq "other"
        end
      end

      context "when the start date comes as a specific datetime" do
        let(:response_body) { super().gsub(fixture_date, "2023-11-21T00:00:00") }

        it "stores it parsed as a specific date" do
          expect(vacancy.starts_on.to_s).to eq("2023-11-21")
          expect(vacancy.start_date_type).to eq "specific_date"
        end
      end

      context "when the start date comes as a specific date in a different format" do
        let(:response_body) { super().gsub(fixture_date, "21.11.23") }

        it "stores it parsed as a specific date" do
          expect(vacancy.starts_on.to_s).to eq("2023-11-21")
          expect(vacancy.start_date_type).to eq "specific_date"
        end
      end

      context "when the start date is a text" do
        let(:response_body) { super().gsub(fixture_date, "TBC") }

        it "stores it as other start date details" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.other_start_date_details).to eq("TBC")
          expect(vacancy.start_date_type).to eq "other"
        end
      end
    end

    describe "job roles mapping" do
      let(:response_body) { super().gsub("Teaching Assistant", job_role) }

      ["Teaching Assistant", "Cover Support Teaching Assistant"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[teaching_assistant]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["teaching_assistant"])
          end
        end
      end

      ["Teacher", "Trainee Teacher", "Cover Support Teacher", "Peripatetic Music", "TLRs", "Lead Practitioner"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[teacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["teacher"])
          end
        end
      end

      ["Principal", "Head of School", "Associate Principal", "Executive Principal"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["headteacher"])
          end
        end
      end

      context "when the source role is 'Vice Principal'" do
        let(:job_role) { "Vice Principal" }

        it "maps the source role to '[deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["deputy_headteacher"])
        end
      end

      context "when the source role is 'Assistant Principal'" do
        let(:job_role) { "Assistant Principal" }

        it "maps the source role to '[assistant_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["assistant_headteacher"])
        end
      end

      ["Head of Department", "Head of Dept"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[head_of_department_or_curriculum]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_department_or_curriculum"])
          end
        end
      end

      ["Head of Phase", "Head of Year"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[head_of_year_or_phase]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
          end
        end
      end

      ["SEN/Inclusion Support", "Pastoral", "Technician", "Librarian"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[education_support]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["education_support"])
          end
        end
      end

      context "when the source role is 'SEN/Inclusion Teacher'" do
        let(:job_role) { "SEN/Inclusion Teacher" }

        it "maps the source role to '[sendco]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["sendco"])
        end
      end
    end

    describe "working patterns mapping" do
      let(:response_body) { super().gsub("Full Time", working_pattern) }

      context "when the working pattern is 'Full Time'" do
        let(:working_pattern) { "Full Time" }

        it "maps the source working pattern to '[full_time]' in the vacancy" do
          expect(vacancy.working_patterns).to eq(["full_time"])
        end
      end

      ["Casual", "Flexible", "Term Time", "Part Time"].each do |pattern|
        context "when the working pattern is '#{pattern}'" do
          let(:working_pattern) { pattern }

          it "maps the source working pattern to '[part_time]' in the vacancy" do
            expect(vacancy.working_patterns).to eq(["part_time"])
          end
        end
      end
    end

    describe "contract type mapping" do
      let(:response_body) { super().gsub("Fixed Term", contract_type) }

      context "when the contract type is 'Permanent'" do
        let(:contract_type) { "Permanent" }

        it "maps the source contract type to 'permanent' in the vacancy" do
          expect(vacancy.contract_type).to eq("permanent")
        end
      end

      ["Casual", "Fixed Term"].each do |pattern|
        context "when the contract type is '#{pattern}'" do
          let(:contract_type) { pattern }

          it "maps the source contract type to 'fixed_term' in the vacancy" do
            expect(vacancy.contract_type).to eq("fixed_term")
          end
        end
      end
    end

    describe "phases mapping" do
      let(:response_body) { super().gsub("All-through", phase) }

      context "when the phase is 'Nursery'" do
        let(:phase) { "Nursery" }

        it "maps the source phase to '[nursery]' in the vacancy" do
          expect(vacancy.phases).to eq(["nursery"])
        end
      end

      context "when the phase is 'Primary'" do
        let(:phase) { "Primary" }

        it "maps the source phase to '[primary]' in the vacancy" do
          expect(vacancy.phases).to eq(["primary"])
        end
      end

      context "when the phase is 'Secondary'" do
        let(:phase) { "Secondary" }

        it "maps the source phase to '[Secondary]' in the vacancy" do
          expect(vacancy.phases).to eq(["secondary"])
        end
      end

      context "when the phase is 'All-through'" do
        let(:phase) { "All-through" }

        it "maps the source phase to '[through]' in the vacancy" do
          expect(vacancy.phases).to eq(["through"])
        end
      end
    end

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phases: %w[primary],
          external_source: VacancySource::Source::Ark::SOURCE_NAME,
          external_reference: "Solomon-1143",
          organisations: schools,
          job_title: "Out of date",
        )
      end

      it "yields the existing vacancy with updated information" do
        expect(vacancy.id).to eq(existing_vacancy.id)
        expect(vacancy).to be_persisted
        expect(vacancy).to be_changed
        expect(vacancy.job_title).to eq("Tutor Fellow (Primary or Secondary)")
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
