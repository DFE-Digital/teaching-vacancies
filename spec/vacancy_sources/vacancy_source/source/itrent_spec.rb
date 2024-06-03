require "rails_helper"

RSpec.describe VacancySource::Source::Itrent do
  let!(:school1) { create(:school, name: "Test School", urn: "12345", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "E-ACT", uid: "456789", schools: trust_schools) }
  let(:trust_schools) { [school1] }

  let(:response_requisition_body) { file_fixture("vacancy_sources/itrent_requisition.json").read }
  let(:response_udf_body) { file_fixture("vacancy_sources/itrent_udf.json").read }
  let(:requisition_response) { double("ItrentHttpResponse", success?: true, body: response_requisition_body) }
  let(:udf_response) { double("ItrentHttpResponse", success?: true, body: response_udf_body) }
  # let(:argument_error_response) { double("ItrentHttpResponse", success?: true, body: file_fixture("vacancy_sources/fusion_argument_error.json").read) }

  describe "enumeration" do
    before do
      expect(HTTParty).to receive(:get).with("http://example.com/feed.json", anything).and_return(requisition_response)
      expect(HTTParty).to receive(:get).with("http://example.com/udf.json", anything).and_return(udf_response)
    end

    let(:vacancy) { subject.first }
    let(:expected_vacancy) do
      {
        job_title: "Class Teacher",
        job_advert: "<p>Lorem Ipsum dolor sit amet</p>",
        salary: "£24,000 to £30,000 depending on working knowledge",
        job_roles: ["teacher"],
        key_stages: %w[ks2],
        working_patterns: %w[full_time],
        contract_type: "fixed_term",
        phases: %w[secondary],
        subjects: ["maths", "advanced maths"],
        visa_sponsorship_available: false,
        benefits_details: "TLR2a",
        ect_status: "ect_suitable",
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

      expect(vacancy.external_source).to eq("itrent")
      expect(vacancy.external_advert_url).to eq("https://teachvacs.itrentdemo.co.uk/ttrent_webrecruitment/wrd/run/ETREC179GF.open?WVID=2750500Wqk&VACANCY_ID=5116820Y9h")
      expect(vacancy.external_reference).to eq("FF00067")

      expect(vacancy.organisations).to eq(trust_schools)
    end

    it "sets important dates" do
      expect(vacancy.expires_at).to eq(Time.zone.parse("2023-06-30T00:00:00"))
      expect(vacancy.publish_on).to eq(Date.parse("07/08/2023"))
    end

    describe "job roles mapping" do
      let(:response_udf_body) { super().gsub("Teacher", source_role) }

      ["null", "", " "].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "the vacancy role is null" do
            expect(vacancy.job_roles).to eq([])
          end
        end
      end

      %w[deputy_headteacher_principal deputy_headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "maps the source role to '[deputy_headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["deputy_headteacher"])
          end
        end
      end

      %w[assistant_headteacher_principal assistant_headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "maps the source role to '[assistant_headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["assistant_headteacher"])
          end
        end
      end

      %w[headteacher_principal headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "maps the source role to '[headteacher]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["headteacher"])
          end
        end
      end

      context "when the source role is 'senior_leader'" do
        let(:source_role) { "senior_leader" }

        it "maps the source role to '[headteacher, assistant_headteacher, deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to contain_exactly("headteacher", "assistant_headteacher", "deputy_headteacher")
        end
      end

      %w[head_of_year_or_phase head_of_year].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "maps the source role to '[head_of_year_or_phase]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
          end
        end
      end

      context "when the source role is 'head_of_department_or_curriculum'" do
        let(:source_role) { "head_of_department_or_curriculum" }

        it "maps the source role to '[head_of_department_or_curriculum]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["head_of_department_or_curriculum"])
        end
      end

      context "when the source role is 'middle_leader'" do
        let(:source_role) { "middle_leader" }

        it "maps the source role to '[head_of_year_or_phase, head_of_department_or_curriculum]' in the vacancy" do
          expect(vacancy.job_roles).to contain_exactly("head_of_year_or_phase", "head_of_department_or_curriculum")
        end
      end

      %w[learning_support other_support science_technician].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "maps the source role to '[education_support]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["education_support"])
          end
        end
      end
    end

    describe "start date mapping" do
      let(:fixture_date) { "2023-05-01" }

      it "stores the specific start date" do
        expect(vacancy.starts_on.to_s).to eq "2023-05-01"
        expect(vacancy.start_date_type).to eq "specific_date"
      end

      context "when the start date is blank" do
        let(:response_requisition_body) { super().gsub(fixture_date, "") }

        it "doesn't store a start date" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.start_date_type).to eq nil
        end
      end

      context "when the start date is not present" do
        let(:response_requisition_body) { super().gsub(/"#{fixture_date}"/, "null") }

        it "doesn't store a start date" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.start_date_type).to eq nil
        end
      end

      context "when the start date is a date with extra data" do
        let(:response_requisition_body) { super().gsub(fixture_date, "2022-11-21 or later") }

        it "stores it as other start date details" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.other_start_date_details).to eq("2022-11-21 or later")
          expect(vacancy.start_date_type).to eq "other"
        end
      end

      context "when the start date comes as a specific datetime" do
        let(:response_requisition_body) { super().gsub(fixture_date, "2023-11-21T00:00:00") }

        it "stores it parsed as a specific date" do
          expect(vacancy.starts_on.to_s).to eq("2023-11-21")
          expect(vacancy.start_date_type).to eq "specific_date"
        end
      end

      context "when the start date comes as a specific date in a different format" do
        let(:response_requisition_body) { super().gsub(fixture_date, "21.11.23") }

        it "stores it parsed as a specific date" do
          expect(vacancy.starts_on.to_s).to eq("2023-11-21")
          expect(vacancy.start_date_type).to eq "specific_date"
        end
      end

      context "when the start date is a text" do
        let(:response_requisition_body) { super().gsub(fixture_date, "TBC") }

        it "stores it as other start date details" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.other_start_date_details).to eq("TBC")
          expect(vacancy.start_date_type).to eq "other"
        end
      end
    end

    describe "phase mapping" do
      let(:response_udf_body) { super().gsub("secondary", phase) }

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
      let(:response_udf_body) do
        JSON.parse(super()).tap { |h|
          h["itrent"]["udfs"].first["ectsuitable"] = ect_suitability
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
          phases: %w[secondary],
          external_source: "itrent",
          external_reference: "FF00067",
          organisations: trust_schools,
          job_title: "Class Teacher",
        )
      end

      it "yields the existing vacancy with updated information" do
        expect(vacancy.id).to eq(existing_vacancy.id)
        expect(vacancy).to be_persisted
        expect(vacancy).to be_changed

        expect(vacancy.job_title).to eq("Class Teacher")
      end
    end

    describe "vacancy organisation parsing" do
      let(:trust_uid) { school_group.uid }
      let(:school_urns) { [school1.urn] }

      let(:response_udf_body) do
        JSON.parse(super()).tap { |h|
          h["itrent"]["udfs"].first["schoolurns"] = school_urns
          h["itrent"]["udfs"].first["trustuid"] = trust_uid
        }.to_json
      end

      context "when the vacancy belongs to a single school" do
        let(:school_urns) { [school1.urn] }

        it "assigns the vacancy to the correct school and organisation" do
          expect(vacancy.organisations.first).to eq(school1)

          expect(vacancy.external_source).to eq("itrent")
          expect(vacancy.external_advert_url).to eq("https://teachvacs.itrentdemo.co.uk/ttrent_webrecruitment/wrd/run/ETREC179GF.open?WVID=2750500Wqk&VACANCY_ID=5116820Y9h")
          expect(vacancy.external_reference).to eq("FF00067")
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
end
