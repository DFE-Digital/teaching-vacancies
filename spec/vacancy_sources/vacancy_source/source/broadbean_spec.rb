require "rails_helper"

RSpec.describe VacancySource::Source::Broadbean do
  let(:response_body) { file_fixture("vacancy_sources/broadbean.xml").read }
  let(:response) { double("BroadbeanHttpResponse", success?: true, body: response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary, created_at: 1.week.ago) }
  let!(:school_group) { create(:school_group, name: "E-ACT", uid: "12345", schools: schools) }
  let(:schools) { [school1] }

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:job_role) { "head_of_year_or_phase" }

    let(:expected_vacancy) do
      {
        job_title: "Class Teacher",
        job_advert: "Non-random descriptive text",
        salary: "£50879 - £85262 per week",
        job_roles: [job_role],
        key_stages: [],
        working_patterns: %w[part_time],
        contract_type: "parental_leave_cover",
        phases: %w[primary],
        visa_sponsorship_available: true,
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

      expect(vacancy.external_source).to eq("broadbean")
      expect(vacancy.external_advert_url).to eq("http://testurl.com")
      expect(vacancy.external_reference).to eq("0044")

      expect(vacancy.organisations).to eq(schools)
    end

    describe "start date mapping" do
      let(:fixture_date) { "20-5-2023" }

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
      let(:response_body) { super().gsub("head_of_year_or_phase", job_role) }

      %w[deputy_headteacher_principal deputy_headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[deputy_headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["deputy_headteacher"])
          end
        end
      end

      %w[assistant_headteacher_principal assistant_headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[assistant_headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["assistant_headteacher"])
          end
        end
      end

      %w[headteacher_principal headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["headteacher"])
          end
        end
      end

      context "when the source role is 'senior_leader'" do
        let(:job_role) { "senior_leader" }

        it "maps the source role to '[headteacher, assistant_headteacher, deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to contain_exactly("headteacher", "assistant_headteacher", "deputy_headteacher")
        end
      end

      %w[head_of_year_or_phase head_of_year].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[head_of_year_or_phase]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
          end
        end
      end

      context "when the source role is 'head_of_department_or_curriculum'" do
        let(:job_role) { "head_of_department_or_curriculum" }

        it "maps the source role to '[head_of_department_or_curriculum]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["head_of_department_or_curriculum"])
        end
      end

      context "when the source role is 'middle_leader'" do
        let(:job_role) { "middle_leader" }

        it "maps the source role to '[head_of_year_or_phase, head_of_department_or_curriculum]' in the vacancy" do
          expect(vacancy.job_roles).to contain_exactly("head_of_year_or_phase", "head_of_department_or_curriculum")
        end
      end

      %w[learning_support other_support science_technician].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_role) { role }

          it "maps the source role to '[education_support]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["education_support"])
          end
        end
      end
    end

    describe "phase mapping" do
      let(:response_body) { super().gsub("primary", phase) }

      %w[16-19 16_19].each do |phase|
        context "when the phase is '#{phase}'" do
          let(:phase) { phase }

          it "maps the phase to '[sixth_form_or_college]' in the vacancy" do
            expect(vacancy.phases).to eq(["sixth_form_or_college"])
          end
        end
      end

      %w[through_school all_through].each do |phase|
        context "when the phase is '#{phase}'" do
          let(:phase) { phase }

          it "maps the phase to '[through]' in the vacancy" do
            expect(vacancy.phases).to eq(["through"])
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
          external_source: "broadbean",
          external_reference: "0044",
          organisations: schools,
          job_title: "Out of date",
        )
      end

      it "yields the existing vacancy with updated information" do
        expect(vacancy.id).to eq(existing_vacancy.id)
        expect(vacancy).to be_persisted
        expect(vacancy).to be_changed

        expect(vacancy.job_title).to eq("Class Teacher")
      end
    end

    context "when multiple school" do
      let(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:schools) { [school1, school2].sort_by(&:created_at) }

      it "assigns the vacancy job location to the central trust" do
        expect(vacancy.readable_job_location).to eq(school1.name)
      end
    end

    context "when the vacancy belongs to the central trust office instead of a particular/multiple school" do
      let(:response_body) { file_fixture("vacancy_sources/broadbean_without_schools.xml").read }

      before do
        create(:school_group, name: "Wrong Trust", uid: "54321", schools: [])
      end

      it "the vacancy is valid" do
        expect(vacancy).to be_valid
      end

      it "assigns the vacancy to the school group" do
        expect(vacancy.organisations).to contain_exactly(school_group)
      end

      it "assigns the vacancy job location to the school group" do
        expect(vacancy.readable_job_location).to eq(school_group.name)
      end
    end

    context "when the school doesn't belong to a school group" do
      let(:response_body) { file_fixture("vacancy_sources/broadbean_without_trust.xml").read }
      let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }

      it "the vacancy is valid" do
        expect(vacancy).to be_valid
      end

      it "assigns the vacancy to the school" do
        expect(vacancy.organisations).to contain_exactly(school2)
      end

      it "assigns the vacancy job location to the school" do
        expect(vacancy.readable_job_location).to eq(school2.name)
      end
    end

    context "when visa_sponsorship_available field is not supplied" do
      let(:response_body) { file_fixture("vacancy_sources/broadbean_without_visa_sponsorship_available.xml").read }

      it "defaults visa_sponsorship_available to false" do
        expect(vacancy.visa_sponsorship_available).to eq false
      end
    end
  end
end
