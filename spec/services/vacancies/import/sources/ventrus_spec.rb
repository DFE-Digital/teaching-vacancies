require "rails_helper"

RSpec.describe Vacancies::Import::Sources::Ventrus do
  let(:response_body) { file_fixture("vacancy_sources/ventrus.xml").read }
  let(:response) { double("VentrusHttpResponse", success?: true, body: response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "Ventrus", uid: "4243", schools: schools) }
  let(:schools) { [school1] }

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:job_roles) { %w[teaching_assistant] }

    let(:expected_vacancy) do
      {
        job_title: "Teaching Assistant",
        job_advert: "<p>This is a random advert text <br> with HTML</p>",
        salary: "£21,575 - £22,369",
        job_roles: job_roles,
        key_stages: ["ks2"],
        working_patterns: %w[part_time],
        contract_type: "permanent",
        phases: %w[secondary],
        visa_sponsorship_available: true,
        ect_status: "ect_suitable",
      }
    end

    before do
      expect(HTTParty).to receive(:get).with("http://example.com/feed.xml").and_return(response)
    end

    it "has the correct number of vacancies" do
      expect(subject.count).to eq(1)
    end

    it "yields vacancies with correct attributes" do
      expect { |b| subject.each(&b) }.to yield_with_args(an_instance_of(PublishedVacancy))
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

    describe "working_patterns mapping" do
      context "when working_patterns includes `flexible`" do
        let(:response_body) { super().gsub("part_time", "full_time,flexible") }

        it "maps flexible to part time" do
          expect(vacancy.working_patterns).to eq %w[full_time part_time]
        end
      end

      context "when working_patterns includes `flexible` and `part_time`" do
        let(:response_body) { super().gsub("part_time", "full_time,part_time,flexible") }

        it "maps flexible to part time" do
          expect(vacancy.working_patterns).to eq %w[full_time part_time]
        end
      end

      context "when working_patterns includes `term_time`" do
        let(:response_body) { super().gsub("part_time", "full_time,term_time") }

        it "maps term_time to part time" do
          expect(vacancy.working_patterns).to eq %w[full_time part_time]
        end
      end

      context "when working_patterns includes `term_time` and `part_time`" do
        let(:response_body) { super().gsub("part_time", "full_time,part_time,term_time") }

        it "maps term_time to part time" do
          expect(vacancy.working_patterns).to eq %w[full_time part_time]
        end
      end

      context "when working pattern includes `job_share`" do
        let(:response_body) { super().gsub("part_time", "job_share") }

        it "maps job_share to part time" do
          expect(vacancy.working_patterns).to eq ["part_time"]
        end

        it "sets is_job_share to true" do
          expect(vacancy.is_job_share).to eq true
        end
      end

      context "when the working patterns list contains spaces" do
        let(:response_body) { super().gsub("part_time", "full_time, part_time") }

        it "records both working patterns in the vacancy" do
          expect(vacancy.working_patterns).to contain_exactly("part_time", "full_time")
        end
      end
    end

    describe "job roles mapping" do
      let(:response_body) { super().gsub("teaching_assistant", job_roles.join(",")) }

      %w[deputy_headteacher_principal deputy_headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[deputy_headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["deputy_headteacher"])
          end
        end
      end

      %w[assistant_headteacher_principal assistant_headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[assistant_headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["assistant_headteacher"])
          end
        end
      end

      %w[headteacher_principal headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["headteacher"])
          end
        end
      end

      context "when the source role is 'senior_leader'" do
        let(:job_roles) { ["senior_leader"] }

        it "maps the source role to '[headteacher, assistant_headteacher, deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to contain_exactly("headteacher", "assistant_headteacher", "deputy_headteacher")
        end
      end

      %w[head_of_year_or_phase head_of_year].each do |role|
        context "when the source role is '#{role}'" do
          let(:job_roles) { [role] }

          it "maps the source role to '[head_of_year_or_phase]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
          end
        end
      end

      context "when the source role is 'head_of_department_or_curriculum'" do
        let(:job_roles) { ["head_of_department_or_curriculum"] }

        it "maps the source role to '[head_of_department_or_curriculum]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["head_of_department_or_curriculum"])
        end
      end

      context "when the source role is 'middle_leader'" do
        let(:job_roles) { ["middle_leader"] }

        it "maps the source role to '[head_of_year_or_phase, head_of_department_or_curriculum]' in the vacancy" do
          expect(vacancy.job_roles).to contain_exactly("head_of_year_or_phase", "head_of_department_or_curriculum")
        end
      end

      %w[learning_support other_support science_technician].each do |role|
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

    describe "phase mapping" do
      let(:response_body) { super().gsub("secondary", phase) }

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

    context "when the vacancy is associated with multiple schools from the trust" do
      let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:schools) { [school1, school2] }

      let(:response_body) { super().gsub("111111", "111111,222222") }

      it "assigns the vacancy to both schools" do
        expect(vacancy.organisations).to contain_exactly(school1, school2)
      end

      it "assigns the vacancy job location to the central trust" do
        expect(vacancy.readable_job_location).to eq(school1.name)
      end
    end

    context "when the vacancy belongs to the central trust office instead of a particular/multiple school" do
      let(:response_body) { super().gsub("111111", "") }

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

    context "when the school doesn't belong to Ventrus school group" do
      let(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:response_body) { super().gsub("111111", "222222") }

      it "assigns the vacancy to the school group" do
        expect(vacancy.organisations).to contain_exactly(school_group)
      end

      it "assigns the vacancy job location to the school group" do
        expect(vacancy.readable_job_location).to eq(school_group.name)
      end

      context "when the school group is not provided" do
        let(:response_body) { super().gsub("4243", "") }

        it "does not import vacancy" do
          expect(subject.count).to eq(0)
        end
      end

      context "when the school group is different to Ventrus" do
        let(:response_body) { super().gsub("4243", "4444") }

        it "does not import vacancy" do
          expect(subject.count).to eq(0)
        end
      end
    end

    context "when the school URN doesn't belong to any school" do
      let(:response_body) { super().gsub("111111", "123456789") }

      it "assigns the vacancy to the school group" do
        expect(vacancy.organisations).to contain_exactly(school_group)
      end

      it "assigns the vacancy job location to the school group" do
        expect(vacancy.readable_job_location).to eq(school_group.name)
      end

      context "when the school group is not provided" do
        let(:response_body) { super().gsub("4243", "") }

        it "does not import vacancy" do
          expect(subject.count).to eq(0)
        end
      end

      context "when the school group is different to Ventrus" do
        let(:response_body) { super().gsub("4243", "4444") }

        it "does not import vacancy" do
          expect(subject.count).to eq(0)
        end
      end
    end

    context "when visa_sponsorship_available field is not supplied" do
      let(:response_body) { file_fixture("vacancy_sources/ventrus_without_visa_sponsorship_available.xml").read }

      it "defaults visa_sponsorship_available to false" do
        expect(vacancy.visa_sponsorship_available).to eq false
      end
    end

    context "when contract_type is parental_leave_cover" do
      let(:response_body) { file_fixture("vacancy_sources/ventrus_with_parental_leave_cover.xml").read }

      it "sets contract_type to fixed_term and is_parental_leave_cover to true" do
        expect(vacancy.contract_type).to eq("fixed_term")
        expect(vacancy.is_parental_leave_cover).to eq(true)
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
