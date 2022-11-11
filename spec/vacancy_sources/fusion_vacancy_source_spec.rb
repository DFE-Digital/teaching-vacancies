require "rails_helper"

RSpec.describe FusionVacancySource do
  let!(:school) { create(:school, name: "Test School", urn: "145506", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "E-ACT", uid: "16614", schools: [school]) }

  let(:response) { double("FusionHttpResponse", success?: true, body: file_fixture("vacancy_sources/fusion.json").read) }

  before do
    expect(HTTParty).to receive(:get).with("http://example.com/feed.json").and_return(response)
  end

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:expected_vacancy) do
      {
        job_title: "Class Teacher",
        job_advert: "Lorem Ipsum dolor sit amet",
        salary: "£25,714.00 to £41,604.00",
        job_role: "teacher",
        key_stages: %w[ks1 ks2],
        working_patterns: %w[full_time],
        contract_type: "fixed_term",
        phases: %w[primary],
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
      expect(vacancy.organisations.first).to eq(school)

      expect(vacancy.external_source).to eq("fusion")
      expect(vacancy.external_advert_url).to eq("http://testurl.com")
      expect(vacancy.external_reference).to eq("0044")

      expect(vacancy.organisations).to eq([school])
    end

    it "sets important dates" do
      expect(vacancy.expires_at).to eq(Time.zone.parse("2022-10-28T12:00:00"))
      expect(vacancy.publish_on).to eq(Date.today)
    end

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phases: %w[primary],
          external_source: "fusion",
          external_reference: "0044",
          organisations: [school],
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
  end
end
