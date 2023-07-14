require "rails_helper"

RSpec.describe UnitedLearningVacancySource do
  let!(:school) { create(:school, name: "Test School", urn: "136636", phase: :secondary) }
  let!(:school_group) { create(:school_group, name: "United Learning", uid: "5143", schools: [school]) }

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

      expect(vacancy.job_role).to eq("teacher")
      expect(vacancy.ect_status).to eq("ect_suitable")
      expect(vacancy.subjects).to eq(%w[Geography])
      expect(vacancy.working_patterns).to eq(%w[full_time])
      expect(vacancy.contract_type).to eq("permanent")
      expect(vacancy.phases).to eq(%w[secondary])

      expect(vacancy.organisations.first).to eq(school)

      expect(vacancy.external_source).to eq("united_learning")
      expect(vacancy.external_advert_url).to eq("https://unitedlearning.current-vacancies.com/Jobs/FeedLink/2648837")
      expect(vacancy.external_reference).to eq("751190")

      expect(vacancy.organisations).to eq([school])

      expect(vacancy.expires_at).to eq(Time.zone.parse("2022-05-15 12:00:00"))
      expect(vacancy.publish_on).to eq(Date.today)
    end

    describe "job roles mapping" do
      let(:item_stub) { instance_double(UnitedLearningVacancySource::FeedItem, :[] => "") }

      before do
        allow(item_stub).to receive(:[]).with("Job_roles").and_return(source_role)
        allow(UnitedLearningVacancySource::FeedItem).to receive(:new).and_return(item_stub)
      end

      [nil, "", " "].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "the vacancy role is null" do
            expect(vacancy.job_role).to eq(nil)
          end
        end
      end

      %w[leadership headteacher deputy_headteacher assistant_headteacher].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "maps the source role to 'senior_leader' in the vacancy" do
            expect(vacancy.job_role).to eq("senior_leader")
          end
        end
      end

      %w[head_of_year_or_phase head_of_department_or_curriculum].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "maps the source role to 'middle_leader' in the vacancy" do
            expect(vacancy.job_role).to eq("middle_leader")
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
