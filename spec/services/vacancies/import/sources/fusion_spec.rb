require "rails_helper"

RSpec.describe Vacancies::Import::Sources::Fusion do
  let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "E-ACT", uid: "12345", schools: trust_schools) }
  let(:trust_schools) { [school1] }

  let(:response_body) { file_fixture("vacancy_sources/fusion.json").read }
  let(:response) { double("FusionHttpResponse", success?: true, body: response_body) }
  let(:argument_error_response) { double("FusionHttpResponse", success?: true, body: file_fixture("vacancy_sources/fusion_argument_error.json").read) }

  describe "enumeration" do
    before do
      expect(HTTParty).to receive(:get).with("http://example.com/feed.json").and_return(response)
    end

    let(:vacancy) { subject.first }
    let(:expected_vacancy) do
      {
        job_title: "Class Teacher",
        job_advert: "Lorem Ipsum dolor sit amet",
        salary: "£25,714.00 to £41,604.00",
        job_roles: ["teacher"],
        key_stages: %w[ks1 ks2],
        working_patterns: %w[full_time],
        contract_type: "fixed_term",
        phases: %w[primary],
        visa_sponsorship_available: true,
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

      expect(vacancy.external_source).to eq("fusion")
      expect(vacancy.external_advert_url).to eq("http://testurl.com")
      expect(vacancy.external_reference).to eq("0044")

      expect(vacancy.organisations).to eq(trust_schools)
    end

    it "sets important dates" do
      expect(vacancy.expires_at).to eq(Time.zone.parse("2022-10-28T12:00:00"))
      expect(vacancy.publish_on).to eq(Date.today)
    end

    describe "job roles mapping" do
      let(:response_body) { super().gsub("teacher", source_roles.join(",")) }

      ["null", "", " "].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_roles) { [role] }

          it "the vacancy roles are empty" do
            expect(vacancy.job_roles).to eq([])
          end
        end
      end

      context "when the source role is 'senior_leader'" do
        let(:source_roles) { ["senior_leader"] }

        it "maps the source role to '[headteacher, assistant_headteacher, deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to contain_exactly("headteacher", "assistant_headteacher", "deputy_headteacher")
        end
      end

      context "when the source role is 'middle_leader'" do
        let(:source_roles) { ["middle_leader"] }

        it "maps the source role to '[head_of_year_or_phase, head_of_department_or_curriculum]' in the vacancy" do
          expect(vacancy.job_roles).to contain_exactly("head_of_year_or_phase", "head_of_department_or_curriculum")
        end
      end

      %w[head_of_year head_of_year_or_phase].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_roles) { [role] }

          it "maps the source role to '[head_of_year_or_phase]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
          end
        end
      end

      context "when the source role is 'learning_support'" do
        let(:source_roles) { ["learning_support"] }

        it "maps the source role to 'other_support' in the vacancy" do
          expect(vacancy.job_roles).to eq(["other_support"])
        end
      end

      context "when the source has multiple roles" do
        let(:source_roles) { %w[teaching_assistant deputy_headteacher] }

        it "maps the source roles to '[teaching_assistant, deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(%w[teaching_assistant deputy_headteacher])
        end
      end
    end

    describe "working_patterns mapping" do
      context "when working_patterns includes `flexible`" do
        let(:response_body) do
          hash = JSON.parse(super())
          hash["result"].first["workingPatterns"] = "full_time,flexible"
          hash.to_json
        end

        it "maps flexible to part time" do
          expect(vacancy.working_patterns).to eq %w[full_time part_time]
        end
      end

      context "when working_patterns includes `flexible` and `part_time`" do
        let(:response_body) do
          hash = JSON.parse(super())
          hash["result"].first["workingPatterns"] = "full_time,part_time,flexible"
          hash.to_json
        end

        it "maps flexible to part time" do
          expect(vacancy.working_patterns).to eq %w[full_time part_time]
        end
      end

      context "when working_patterns includes `term_time`" do
        let(:response_body) do
          hash = JSON.parse(super())
          hash["result"].first["workingPatterns"] = "full_time,term_time"
          hash.to_json
        end

        it "maps term_time to part time" do
          expect(vacancy.working_patterns).to eq %w[full_time part_time]
        end
      end

      context "when working_patterns includes `term_time` and `part_time`" do
        let(:response_body) do
          hash = JSON.parse(super())
          hash["result"].first["workingPatterns"] = "full_time,part_time,term_time"
          hash.to_json
        end

        it "maps term_time to part time" do
          expect(vacancy.working_patterns).to eq %w[full_time part_time]
        end
      end

      context "when working pattern includes `job_share`" do
        let(:response_body) do
          hash = JSON.parse(super())
          hash["result"].first["workingPatterns"] = "job_share"
          hash.to_json
        end

        it "maps job_share to part time" do
          expect(vacancy.working_patterns).to eq ["part_time"]
        end

        it "sets is_job_share to true" do
          expect(vacancy.is_job_share).to eq true
        end
      end

      context "when the working patterns list contains spaces" do
        let(:response_body) do
          hash = JSON.parse(super())
          hash["result"].first["workingPatterns"] = "full_time, part_time, term_time"
          hash.to_json
        end

        it "records both working patterns in the vacancy" do
          expect(vacancy.working_patterns).to contain_exactly("part_time", "full_time")
        end
      end
    end

    describe "start date mapping" do
      let(:fixture_date) { "2022-11-21T00:00:00" }

      it "stores the specific start date" do
        expect(vacancy.starts_on.to_s).to eq "2022-11-21"
        expect(vacancy.start_date_type).to eq "specific_date"
      end

      context "when the start date is blank" do
        let(:response_body) { super().gsub(fixture_date, "") }

        it "doesn't store a start date" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.start_date_type).to eq nil
        end
      end

      context "when the start date is not present" do
        let(:response_body) { super().gsub(/"#{fixture_date}"/, "null") }

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

    context "when contract_type is parental_leave_cover" do
      let(:response_body) { super().gsub("fixed_term", "parental_leave_cover") }

      it "sets contract_type to fixed_term and is_parental_leave_cover to true" do
        expect(vacancy.contract_type).to eq("fixed_term")
        expect(vacancy.is_parental_leave_cover).to eq(true)
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

    describe "working_patterns" do
      let(:response_body) { super().gsub("full_time", "job_share") }

      context "when vacancy is a job share" do
        it "sets vacancy to part time and is_job_share to true" do
          expect(vacancy.working_patterns).to eq(["part_time"])
          expect(vacancy.is_job_share).to eq(true)
        end
      end
    end

    describe "ect suitability mapping" do
      let(:response_body) do
        JSON.parse(super()).tap { |h|
          h["result"].first["ectSuitable"] = ect_suitability
        }.to_json
      end

      context "when the vacancy is suitable for an ECT" do
        let(:ect_suitability) { true }

        it "sets the vacancy as suitable for an ECT" do
          expect(vacancy.ect_status).to eq("ect_suitable")
        end
      end

      context "when the vacancy is not suitable for an ECT" do
        let(:ect_suitability) { false }

        it "sets the vacancy as not suitable for an ECT" do
          expect(vacancy.ect_status).to eq("ect_unsuitable")
        end
      end

      context "when the vacancy suitability for an ECT is not provided" do
        let(:ect_suitability) { nil }

        it "sets the vacancy as not suitable for an ECT" do
          expect(vacancy.ect_status).to eq("ect_unsuitable")
        end
      end
    end

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phases: %w[primary],
          external_source: "fusion",
          external_reference: "0044",
          organisations: trust_schools,
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

    context "when visa_sponsorship_available is not provided" do
      let(:response_body) do
        hash = JSON.parse(super())
        hash["result"].first.delete("visaSponsorshipAvailable")
        hash.to_json
      end

      it "sets visa_sponsorship_available to false" do
        expect(vacancy.visa_sponsorship_available).to eq false
      end
    end

    describe "vacancy organisation parsing" do
      let(:trust_uid) { school_group.uid }
      let(:school_urns) { [school1.urn] }

      let(:response_body) do
        JSON.parse(super()).tap { |h|
          h["result"].first["schoolUrns"] = school_urns
          h["result"].first["trustUID"] = trust_uid
        }.to_json
      end

      context "when the vacancy belongs to a single school" do
        let(:school_urns) { [school1.urn] }

        it "assigns the vacancy to the correct school and organisation" do
          expect(vacancy.organisations.first).to eq(school1)

          expect(vacancy.external_source).to eq("fusion")
          expect(vacancy.external_advert_url).to eq("http://testurl.com")
          expect(vacancy.external_reference).to eq("0044")
        end
      end

      context "when associated with an out of scope school" do
        let(:out_of_scope_school) { create(:school, detailed_school_type: "Other independent school", urn: "000000") }
        let(:trust_schools) { [out_of_scope_school] }
        let(:school_urns) { [out_of_scope_school.urn] }

        it "does not import vacancy" do
          expect(subject.count).to eq(0)
        end
      end

      context "when the vacancy is associated with multiple schools from a trust" do
        let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
        let(:trust_schools) { [school1, school2].sort_by(&:created_at) }
        let(:school_urns) { [school1.urn, school2.urn] }

        it "assigns the vacancy to both schools" do
          expect(vacancy.organisations).to contain_exactly(school1, school2)
        end

        it "assigns the vacancy job location to the first school from the group" do
          expect(vacancy.readable_job_location).to eq(school1.name)
        end
      end

      context "when the vacancy belongs to the central trust office instead of a particular/multiple school" do
        let(:school_urns) { [] }

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

        context "when the provided central trust does not exist in our system" do
          let(:trust_uid) { "invalid_trust_id" }

          it "skips the vacancy" do
            expect(vacancy).to be_nil
          end
        end
      end

      context "when the school doesn't belong to a school group" do
        let(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
        let(:school_urns) { [school2.urn] }
        let(:trust_uid) { nil }

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
    end
  end

  describe "enumeration error" do
    before do
      expect(HTTParty).to receive(:get).with("http://example.com/feed.json").and_return(argument_error_response)
    end

    let(:vacancy) { subject.first }

    context "when incorrect values are provided" do
      it "adds an error to the vacancy object" do
        expect(vacancy.errors.count).to eq(1)
      end
    end
  end
end
