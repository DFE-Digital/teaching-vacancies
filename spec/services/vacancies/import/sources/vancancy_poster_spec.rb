require "rails_helper"

RSpec.describe Vacancies::Import::Sources::VacancyPoster do
  let(:response_body) { file_fixture("vacancy_sources/vacancy_poster.xml").read }
  let(:response) { double("VacancyPosterHttpResponse", success?: true, body: response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "123456", phase: :primary) }
  let(:schools) { [school1] }

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:job_role) { "deputy_headteacher" }

    let(:expected_vacancy) do
      {
        job_title: "Test Post",
        job_advert: "What is the job role? Castle Wood is an outstanding special school.",
        salary: "£80000",
        job_roles: [job_role],
        key_stages: ["ks5"],
        working_patterns: %w[full_time],
        contract_type: "permanent",
        phases: %w[primary],
        visa_sponsorship_available: false,
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

      expect(vacancy.external_source).to eq("vacancy_poster")
      expect(vacancy.external_advert_url).to eq("www.company.com/jobs/12345?jobboard=Teaching+Vacancies&amp;c=vacancyposter")
      expect(vacancy.external_reference).to eq("TEST002")

      expect(vacancy.organisations).to eq(schools)
    end

    describe "working_patterns mapping" do
      context "when working_patterns includes `flexible`" do
        let(:response_body) { super().gsub("full_time", "full_time,flexible") }
  
        it "maps flexible to part time" do
          expect(vacancy.working_patterns).to eq ["full_time", "part_time"]
        end
      end
  
      context "when working_patterns includes `flexible` and `part_time`" do
        let(:response_body) { super().gsub("full_time", "full_time,part_time,flexible") }
  
        it "maps flexible to part time" do
          expect(vacancy.working_patterns).to eq ["full_time", "part_time"]
        end
      end
  
      context "when working_patterns includes `term_time`" do
        let(:response_body) { super().gsub("full_time", "full_time,term_time") }
  
        it "maps term_time to part time" do
          expect(vacancy.working_patterns).to eq ["full_time", "part_time"]
        end
      end
  
      context "when working_patterns includes `term_time` and `part_time`" do
        let(:response_body) { super().gsub("full_time", "full_time,part_time,term_time") }
    
        it "maps term_time to part time" do
          expect(vacancy.working_patterns).to eq ["full_time", "part_time"]
        end
      end

      context "when working pattern includes `job_share`" do
        let(:response_body) { super().gsub("full_time", "job_share") }
    
        it "maps job_share to part time" do
          expect(vacancy.working_patterns).to eq ["part_time"]
        end

        it "sets is_job_share to true" do
          expect(vacancy.is_job_share).to eq true
        end
      end

      context "when the working patterns list contains spaces" do
        let(:response_body) { super().gsub("full_time", "full_time, part_time") }

        it "records both working patterns in the vacancy" do
          expect(vacancy.working_patterns).to contain_exactly("part_time", "full_time")
        end
      end
    end

    describe "job roles mapping" do
      let(:response_body) { super().gsub("deputy_headteacher", job_role) }

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

      context "when the phase is 'through_school'" do
        let(:phase) { "through_school" }

        it "maps the phase to '[through]' in the vacancy" do
          expect(vacancy.phases).to eq(["through"])
        end
      end
    end

    context "when contract_type is parental_leave_cover" do
      let(:response_body) { super().gsub("permanent", "parental_leave_cover") }

      it "sets contract_type to fixed_term and is_parental_leave_cover to true" do
        expect(vacancy.contract_type).to eq("fixed_term")
        expect(vacancy.is_parental_leave_cover).to eq(true)
      end
    end

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phases: %w[primary],
          external_source: "vacancy_poster",
          external_reference: "TEST002",
          organisations: schools,
          job_title: "Out of date",
        )
      end

      it "yields the existing vacancy with updated information" do
        expect(vacancy.id).to eq(existing_vacancy.id)
        expect(vacancy).to be_persisted
        expect(vacancy).to be_changed

        expect(vacancy.job_title).to eq("Test Post")
      end
    end
  end
end
