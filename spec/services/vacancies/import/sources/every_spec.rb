require "rails_helper"

RSpec.describe Vacancies::Import::Sources::Every do
  let(:response_body) { file_fixture("vacancy_sources/every.json").read }
  let(:response) { double("EveryHttpResponse", success?: true, body: response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "E-ACT", uid: "12345", schools: schools) }
  let(:schools) { [school1] }

  let(:vacancy) { subject.first }
  let(:job_roles) { ["teacher"] }

  let(:expected_vacancy) do
    {
      job_title: "Class Teacher",
      job_advert: "Lorem Ipsum dolor sit amet",
      salary: "£25,714.00 to £41,604.00",
      job_roles: job_roles,
      key_stages: %w[ks1 ks2],
      working_patterns: %w[full_time],
      contract_type: "fixed_term",
      phases: %w[primary],
      visa_sponsorship_available: true,
    }
  end

  before do
    expect(HTTParty).to receive(:get).with("http://example.com/feed.json").and_return(response)
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

    expect(vacancy.external_source).to eq("every")
    expect(vacancy.external_advert_url).to eq("http://testurl.com")
    expect(vacancy.external_reference).to eq("0044")

    expect(vacancy.organisations).to eq(schools)
  end

  context "when multiple school" do
    let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
    let(:schools) { [school1, school2] }

    it "assigns the vacancy job location to the central trust" do
      expect(vacancy.readable_job_location).to eq(school_group.name)
    end
  end

  context "when the school doesn't belong to a school group" do
    let(:response_body) { file_fixture("vacancy_sources/every_without_trust.json").read }
    let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }

    it "the vacancy is valid" do
      expect(vacancy).to be_valid
    end

    it "assigns the vacancy to the school" do
      expect(vacancy.organisations).to eq([school2])
    end

    it "assigns the vacancy job location to the school" do
      expect(vacancy.readable_job_location).to eq(school2.name)
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

  context "when the same vacancy has been imported previously" do
    let!(:existing_vacancy) do
      create(
        :vacancy,
        :external,
        phases: %w[primary],
        external_source: "every",
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

  describe "working_patterns mapping" do
    context "when working_patterns includes `flexible`" do
      let(:response_body) do
        hash = JSON.parse(super())
        hash["result"].first["workingPatterns"] = "full_time,flexible"
        hash.to_json
      end

      it "maps flexible to part time" do
        expect(vacancy.working_patterns).to eq ["full_time", "part_time"]
      end
    end

    context "when working_patterns includes `flexible` and `part_time`" do
      let(:response_body) do
        hash = JSON.parse(super())
        hash["result"].first["workingPatterns"] = "full_time,part_time,flexible"
        hash.to_json
      end

      it "maps flexible to part time" do
        expect(vacancy.working_patterns).to eq ["full_time", "part_time"]
      end
    end

    context "when working_patterns includes `term_time`" do
      let(:response_body) do
        hash = JSON.parse(super())
        hash["result"].first["workingPatterns"] = "full_time,term_time"
        hash.to_json
      end

      it "maps term_time to part time" do
        expect(vacancy.working_patterns).to eq ["full_time", "part_time"]
      end
    end

    context "when working_patterns includes `term_time` and `part_time`" do
      let(:response_body) do
        hash = JSON.parse(super())
        hash["result"].first["workingPatterns"] = "full_time,part_time,term_time"
        hash.to_json
      end
  
      it "maps term_time to part time" do
        expect(vacancy.working_patterns).to eq ["full_time", "part_time"]
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

  describe "job roles mapping" do
    let(:response_body) { super().gsub("teacher", job_roles.join(",")) }

    context "when the source role is 'senior_leader'" do
      let(:job_roles) { ["senior_leader"] }

      it "maps the source role to '[headteacher, assistant_headteacher, deputy_headteacher]' in the vacancy" do
        expect(vacancy.job_roles).to contain_exactly("headteacher", "assistant_headteacher", "deputy_headteacher")
      end
    end

    context "when the source role is 'middle_leader'" do
      let(:job_roles) { ["middle_leader"] }

      it "maps the source role to '[head_of_year_or_phase, head_of_department_or_curriculum]' in the vacancy" do
        expect(vacancy.job_roles).to contain_exactly("head_of_year_or_phase", "head_of_department_or_curriculum")
      end
    end

    context "when the source role is 'deputy_headteacher_principal'" do
      let(:job_roles) { ["deputy_headteacher_principal"] }

      it "maps the source role to '[deputy_headteacher]' in the vacancy" do
        expect(vacancy.job_roles).to eq(["deputy_headteacher"])
      end
    end

    context "when the source role is 'assistant_headteacher_principal'" do
      let(:job_roles) { ["assistant_headteacher_principal"] }

      it "maps the source role to '[assistant_headteacher]' in the vacancy" do
        expect(vacancy.job_roles).to eq(["assistant_headteacher"])
      end
    end

    context "when the source role is 'headteacher_principal'" do
      let(:job_roles) { ["headteacher_principal"] }

      it "maps the source roles to '[headteacher]' in the vacancy" do
        expect(vacancy.job_roles).to eq(["headteacher"])
      end
    end

    context "when the source role is 'head_of_year'" do
      let(:job_roles) { ["head_of_year"] }

      it "maps the source roles to '[head_of_year_or_phase]' in the vacancy" do
        expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
      end
    end

    %w[learning_support other_support science_technician].each do |role|
      context "when the source role is '#{role}'" do
        let(:job_roles) { [role] }

        it "maps the source roles to '[education_support]' in the vacancy" do
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

  describe "start date mapping" do
    let(:fixture_date) { "2022-11-21T00:00:00" }

    context "when the start date contains a specific date" do
      let(:response_body) { super().gsub(fixture_date, "2022-11-21") }

      it "stores the specific start date" do
        expect(vacancy.starts_on.to_s).to eq "2022-11-21"
        expect(vacancy.start_date_type).to eq "specific_date"
      end
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

  context "when school associated with vacancy is of excluded type" do
    before do
      school1.update(detailed_school_type: "Other independent school")
    end

    it "does not import vacancy" do
      expect(subject.count).to eq(0)
    end
  end

  context "when contract_type is parental_leave_cover" do
    let(:response_body) { super().gsub("fixed_term", "parental_leave_cover") }

    it "sets contract_type to fixed_term and is_parental_leave_cover to true" do
      expect(vacancy.contract_type).to eq("fixed_term")
      expect(vacancy.is_parental_leave_cover).to eq(true)
    end
  end
end
