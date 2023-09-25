require "rails_helper"

RSpec.describe VacancySource::Source::UnitedLearning do
  let!(:school) { create(:school, name: "Test School", urn: "136636", phase: :secondary) }
  let!(:school_group) { create(:school_group, name: "United Learning", uid: described_class::UNITED_LEARNING_TRUST_UID, schools: [school]) }

  describe "enumeration" do
    before do
      # FIXME: Manually stubbing HTTParty because of weird interactions between VCR and Webmock
      expect(HTTParty).to receive(:get).with("http://example.com/feed.xml").and_return(file_fixture("vacancy_sources/united_learning.xml").read)
    end

    let(:vacancy) { subject.first }

    it "has the correct number of vacancies" do
      expect(subject.count).to eq(1)
    end

    it "yield a newly built vacancy the correct vacancy information" do
      expect(vacancy).not_to be_persisted
      expect(vacancy).to be_changed

      expect(vacancy.job_title).to eq("Head of Geography")
      expect(vacancy.job_advert).to eq("Lorem ipsum dolor sit amet")
      expect(vacancy.salary).to eq("PT/EPT + TLR 2B")

      expect(vacancy.job_roles).to eq(["teacher"])
      expect(vacancy.ect_status).to eq("ect_suitable")
      expect(vacancy.subjects).to eq(%w[Geography])
      expect(vacancy.working_patterns).to eq(%w[full_time])
      expect(vacancy.contract_type).to eq("permanent")
      expect(vacancy.phases).to eq(%w[secondary])
      expect(vacancy.visa_sponsorship_available).to eq false

      expect(vacancy.organisations.first).to eq(school)

      expect(vacancy.external_source).to eq("united_learning")
      expect(vacancy.external_advert_url).to eq("https://unitedlearning.current-vacancies.com/Jobs/FeedLink/2648837")
      expect(vacancy.external_reference).to eq("751190")

      expect(vacancy.organisations).to eq([school])

      expect(vacancy.expires_at).to eq(Time.zone.parse("2022-05-15 12:00:00"))
      expect(vacancy.publish_on).to eq(Date.today)
    end

    context "whente there is no school matching the source URN" do
      let!(:school) { create(:school, name: "Test School", urn: "wrong_urn", phase: :secondary) }

      it "the vacancy does not has any associated organisation" do
        expect(vacancy.organisations).to be_empty
      end
    end

    describe "mappings" do
      let(:item_stub) { instance_double(described_class::FeedItem, :[] => "") }

      before do
        allow(item_stub).to receive(:[]).with("Job_roles").and_return("teacher")
        allow(item_stub).to receive(:[]).with("Phase").and_return("Secondary")
        allow(item_stub).to receive(:[]).with("URN").and_return(school.urn)
        allow(item_stub).to receive(:[]).with("Working_patterns").and_return("full_time")
        allow(described_class::FeedItem).to receive(:new).and_return(item_stub)
      end

      describe "job roles mapping" do
        before do
          allow(item_stub).to receive(:[]).with("Job_roles").and_return(source_role)
        end

        ["null", "", " "].each do |role|
          context "when the source role is '#{role}'" do
            let(:source_role) { role }

            it "the vacancy roles are empty" do
              expect(vacancy.job_roles).to eq([])
            end
          end
        end

        %w[senior_leader leadership].each do |role|
          context "when the source role is '#{role}'" do
            let(:source_role) { role }

            it "maps the source role to '[headteacher, assistant_headteacher, deputy_headteacher]' in the vacancy" do
              expect(vacancy.job_roles).to contain_exactly("headteacher", "assistant_headteacher", "deputy_headteacher")
            end
          end
        end

        context "when the source role is 'middle_leader'" do
          let(:source_role) { "middle_leader" }

          it "maps the source role to '[head_of_year_or_phase, head_of_department_or_curriculum]' in the vacancy" do
            expect(vacancy.job_roles).to contain_exactly("head_of_year_or_phase", "head_of_department_or_curriculum")
          end
        end
      end

      describe "phase mapping" do
        before do
          allow(item_stub).to receive(:[]).with("Phase").and_return(phase)
        end

        %w[16-19 16_19].each do |phase|
          context "when the phase is '#{phase}'" do
            let(:phase) { phase }

            it "maps the phase to '[sixth_form_or_college]' in the vacancy" do
              expect(vacancy.phases).to eq(["sixth_form_or_college"])
            end
          end
        end

        context "when the phase is 'Primary'" do
          let(:phase) { "Primary" }

          it "maps the phase to '[primary]' in the vacancy" do
            expect(vacancy.phases).to eq(["primary"])
          end
        end

        context "when the phase is 'Secondary'" do
          let(:phase) { "Secondary" }

          it "maps the phase to '[secondary]' in the vacancy" do
            expect(vacancy.phases).to eq(["secondary"])
          end
        end

        context "when the phase is 'through_school'" do
          let(:phase) { "through_school" }

          it "maps the phase to '[through]' in the vacancy" do
            expect(vacancy.phases).to eq(["through"])
          end
        end
      end

      describe "working patterns mapping" do
        before do
          allow(item_stub).to receive(:[]).with("Working_patterns").and_return(working_patterns)
        end

        context "when the working patterns contain both part and full time" do
          let(:working_patterns) { "part_time,full_time" }

          it "records both working patterns in the vacancy" do
            expect(vacancy.working_patterns).to contain_exactly("part_time", "full_time")
          end
        end

        context "when the working patterns list contains spaces" do
          let(:working_patterns) { "part_time , full_time" }

          it "records both working patterns in the vacancy" do
            expect(vacancy.working_patterns).to contain_exactly("part_time", "full_time")
          end
        end

        context "when the working patterns contain a legacy part time working pattern" do
          let(:working_patterns) { "flexible" }

          it "maps the working patterns to '[part_time]' in the vacancy" do
            expect(vacancy.working_patterns).to eq(["part_time"])
          end
        end

        context "when the working patterns contain multiple legacy part time working pattern" do
          let(:working_patterns) { "flexible,term_time,job_share" }

          it "maps the working patterns to a single '[part_time]' in the vacancy" do
            expect(vacancy.working_patterns).to eq(["part_time"])
          end
        end

        context "when the working patterns combine legacy and non legancy part_time working patterns" do
          let(:working_patterns) { "part_time,flexible" }

          it "maps the working patterns to a single '[part_time]' in the vacancy" do
            expect(vacancy.working_patterns).to eq(["part_time"])
          end
        end

        context "when the working patterns combine legacy and non legancy non part_time working patterns" do
          let(:working_patterns) { "job_share, full_time" }

          it "maps the working patterns to '[part_time, full_time]' in the vacancy" do
            expect(vacancy.working_patterns).to eq(%w[part_time full_time])
          end
        end
      end
    end

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phases: %w[secondary],
          external_source: "united_learning",
          external_reference: "751190",
          organisations: [school],
          job_title: "Out of date",
        )
      end

      it "yields the existing vacancy with updated information" do
        expect(vacancy.id).to eq(existing_vacancy.id)
        expect(vacancy).to be_persisted
        expect(vacancy).to be_changed

        expect(vacancy.job_title).to eq("Head of Geography")
      end
    end
  end

  describe "enumeration error" do
    before do
      # FIXME: Manually stubbing HTTParty because of weird interactions between VCR and Webmock
      expect(HTTParty).to receive(:get).with("http://example.com/feed.xml").and_return(file_fixture("vacancy_sources/united_learning_argument_error.xml").read)
    end

    let(:vacancy) { subject.first }

    context "when incorrect values are provided" do
      it "adds an error to the vacancy object" do
        expect(vacancy.errors.count).to eq(1)
      end
    end
  end
end
