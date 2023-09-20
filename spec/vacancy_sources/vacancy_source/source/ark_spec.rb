require "rails_helper"

RSpec.describe VacancySource::Source::Ark do
  let(:response_body) { file_fixture("vacancy_sources/ark.xml").read }
  let(:response) { double("ArkHttpResponse", success?: true, body: response_body) }

  let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "Ark", uid: "2157", schools: schools) }
  let(:schools) { [school1] }

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:job_role) { "teaching_assistant" }

    let(:expected_vacancy) do
      {
        job_title: "Tutor Fellow (Primary or Secondary)",
        job_advert: "A one year programme that prepares you to enter teacher training, in primary or secondary.",
        salary: "From £24,454",
        job_roles: [job_role],
        key_stages: [],
        working_patterns: %w[full_time],
        contract_type: "fixed_term",
        phases: %w[through],
        visa_sponsorship_available: nil,
        expires_at: Time.zone.parse("2023-09-26T09:00:00"),
        publish_on: Date.parse("2021-03-09"),
      }
    end

    before do
      expect(HTTParty).to receive(:get).with(VacancySource::Source::Ark::FEED_URL).and_return(response)
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

      expect(vacancy.external_source).to eq("ark")
      expect(vacancy.external_advert_url).to eq("http://testurl.com")
      expect(vacancy.external_reference).to eq("Solomon-1143")

      expect(vacancy.organisations).to eq(schools)
    end

    describe "start date mapping" do
      let(:fixture_date) { "2023-05-20" }

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

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phases: %w[primary],
          external_source: VacancySource::Source::Ark::SOURCE_NAME,
          external_reference: "Solomon-1143",
          organisations: schools,
          job_title: "Out of date",
        )
      end

      it "yields the existing vacancy with updated information" do
        expect(vacancy.id).to eq(existing_vacancy.id)
        expect(vacancy).to be_persisted
        expect(vacancy).to be_changed
        expect(vacancy.job_title).to eq("Tutor Fellow (Primary or Secondary)")
      end
    end

    context "when multiple school" do
      let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:schools) { [school1, school2] }

      it "assigns the vacancy job location to the central trust" do
        expect(vacancy.readable_job_location).to eq(school1.name)
      end
    end
  end
end
