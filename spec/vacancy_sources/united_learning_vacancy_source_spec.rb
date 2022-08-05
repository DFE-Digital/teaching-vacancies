require "rails_helper"

RSpec.describe UnitedLearningVacancySource do
  let!(:school) { create(:school, name: "Test School", urn: "136636") }
  let!(:school_group) { create(:school_group, name: "United Learning", uid: "5143", schools: [school]) }

  before do
    # FIXME: Manually stubbing HTTParty because of weird interactions between VCR and Webmock
    expect(HTTParty).to receive(:get).with("http://example.com/feed.xml").and_return(file_fixture("vacancy_sources/united_learning.xml").read)
  end

  describe "enumeration" do
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
      expect(vacancy.phase).to eq("multiple_phases")

      expect(vacancy.organisations.first).to eq(school)

      expect(vacancy.external_source).to eq("united_learning")
      expect(vacancy.external_advert_url).to eq("https://unitedlearning.current-vacancies.com/Jobs/FeedLink/2648837")
      expect(vacancy.external_reference).to eq("751190")

      expect(vacancy.organisations).to eq([school])

      expect(vacancy.expires_at).to eq(Time.zone.parse("2022-05-15 12:00:00"))
      expect(vacancy.publish_on).to eq(Date.today)
    end

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phase: "secondary",
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
end
