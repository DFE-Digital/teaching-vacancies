require "rails_helper"

RSpec.describe VacancySource::Source::Ark do
  let(:response_body) { file_fixture("vacancy_sources/ark.xml").read }
  let(:response) { double("ArkHttpResponse", success?: true, body: response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "Ark", uid: "2157", schools: schools) }
  let(:schools) { [school1] }

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:job_roles) { %w[teaching_assistant] }

    let(:expected_vacancy) do
      {
        job_title: "Tutor Fellow (Primary or Secondary)",
        job_advert: "A one year programme that prepares you to enter teacher training, in primary or secondary.",
        salary: "From £24,454",
        job_roles: job_roles,
        key_stages: [],
        working_patterns: %w[full_time],
        contract_type: "fixed_term",
        phases: %w[through],
        expires_at: Time.zone.parse("2023-10-12T12:00:00"),
        publish_on: Date.parse("2021-03-09"),
        visa_sponsorship_available: true,
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
      let(:response_body) { super().gsub("Teaching Assistant", job_roles.join(",")) }

      ["Teaching Assistant", "Cover Support Teaching Assistant"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[teaching_assistant]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["teaching_assistant"])
          end
        end
      end

      ["Teacher", "Trainee Teacher", "Cover Support Teacher", "Peripatetic Music", "TLRs", "Lead Practitioner"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[teacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["teacher"])
          end
        end
      end

      ["Principal", "Head of School", "Associate Principal", "Executive Principal"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["headteacher"])
          end
        end
      end

      context "when the source role is 'Vice Principal'" do
        let(:job_roles) { ["Vice Principal"] }

        it "maps the source role to '[deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["deputy_headteacher"])
        end
      end

      context "when the source role is 'Assistant Principal'" do
        let(:job_roles) { ["Assistant Principal"] }

        it "maps the source role to '[assistant_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["assistant_headteacher"])
        end
      end

      ["Head of Department", "Head of Dept"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[head_of_department_or_curriculum]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_department_or_curriculum"])
          end
        end
      end

      ["Head of Phase", "Head of Year"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[head_of_year_or_phase]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
          end
        end
      end

      ["School Nurse", "Pastoral"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[pastoral_health_and_welfare]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["pastoral_health_and_welfare"])
          end
        end
      end

      ["SEN/Inclusion Support", "Technician", "Librarian"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[education_support]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["education_support"])
          end
        end
      end

      context "when the source role is 'SEN/Inclusion Teacher'" do
        let(:job_roles) { ["SEN/Inclusion Teacher"] }

        it "maps the source role to '[sendco]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["sendco"])
        end
      end

      ["Finance", "HR", "School Admin", "Data"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[administration_hr_data_and_finance]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["administration_hr_data_and_finance"])
          end
        end
      end

      ["Estates &amp; Premises", "Catering", "Cleaning"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[catering_cleaning_and_site_management]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["catering_cleaning_and_site_management"])
          end
        end
      end

      context "when the source role is 'Operations Leadership'" do
        let(:job_roles) { ["Operations Leadership"] }

        it "maps the source role to '[other_leadership]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["other_leadership"])
        end
      end

      ["School Marketing and Comms", "Governance", "Exam Invigilator"].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[other_support]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["other_support"])
          end
        end
      end

      context "when the source has multiple roles" do
        let(:job_roles) { %w[teaching_assistant deputy_headteacher] }

        it "maps the source roles to '[teaching_assistant, deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(%w[teaching_assistant deputy_headteacher])
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

    context "when visa_sponsorship_available field is not supplied" do
      let(:response_body) { file_fixture("vacancy_sources/ark_without_visa_sponsorship_available.xml").read }

      it "defaults visa_sponsorship_available to false" do
        expect(vacancy.visa_sponsorship_available).to eq false
      end
    end

    context "when school associated with vacancy is of excluded type" do
      before do
        school1.update(detailed_school_type: "Other independent school")
      end

      it "does not import vacancy" do
        expect(subject.count).to eq(0)
      end
    end
  end
end
