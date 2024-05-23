require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::NewAndEdited::ParsedVacancy do
  let(:vacancy) { build_stubbed(:vacancy, :published) }

  subject(:parsed) { described_class.new(vacancy) }

  describe "#id" do
    it "returns the vacancy id" do
      expect(parsed.id).to eq(vacancy.id)
    end
  end

  describe "#job_title" do
    it "returns the vacancy job title" do
      expect(parsed.job_title).to eq(vacancy.job_title)
    end
  end

  describe "#organisation" do
    it "returns the vacancy organisation" do
      organisation = build_stubbed(:school)
      allow(vacancy).to receive(:organisation).and_return(organisation)

      expect(parsed.organisation).to eq(organisation)
    end
  end

  describe "#apply_url" do
    it "returns the vacancy full url" do
      allow(vacancy).to receive(:slug).and_return("job-title-slug")

      expect(parsed.apply_url).to eq("http://#{DOMAIN}/jobs/job-title-slug")
    end
  end

  describe "#category_id" do
    it "returns the IT category id if the vacancy job role is it_support" do
      allow(vacancy).to receive(:job_roles).and_return(["it_support"])

      expect(parsed.category_id).to eq(described_class::CATEGORY_IT_ID)
    end

    it "returns the Education category id if the vacancy job role is not it_support" do
      allow(vacancy).to receive(:job_roles).and_return(["teacher"])

      expect(parsed.category_id).to eq(described_class::CATEGORY_EDUCATION_ID)
    end

    it "returns the IT category id if the vacancy job role is it_support and other" do
      allow(vacancy).to receive(:job_roles).and_return(%w[it_support teacher])

      expect(parsed.category_id).to eq(described_class::CATEGORY_IT_ID)
    end
  end

  describe "#description" do
    it "returns the vacancy job advert without html tags" do
      allow(vacancy).to receive(:job_advert).and_return(
        "<p>Job description with <strong>html</strong> and a <a href='http://example.com'>link</a></p>",
      )
      expect(parsed.description).to eq("Job description with html and a link")
    end
  end

  describe "#expiry" do
    before { travel_to(Time.zone.local(2024, 5, 1, 10, 55, 30)) }
    after { travel_back }

    it "returns the vacancy expiry date as a string if it is between today and 30 days in the future" do
      allow(vacancy).to receive(:expires_at).and_return(Date.today + 15.days)

      expect(parsed.expiry).to eq("2024-05-16")
    end

    it "returns nil if the vacancy expiry date is before today" do
      allow(vacancy).to receive(:expires_at).and_return(Date.yesterday)

      expect(parsed.expiry).to be_nil
    end

    it "returns nil if the vacancy expiry date is today" do
      allow(vacancy).to receive(:expires_at).and_return(Date.yesterday)

      expect(parsed.expiry).to be_nil
    end

    it "returns nil if the vacancy expiry date is more than 30 days in the future" do
      allow(vacancy).to receive(:expires_at).and_return(Date.today + 31.days)

      expect(parsed.expiry).to be_nil
    end
  end

  describe "#status_id" do
    it "returns the full time status id if the vacancy working patterns include full_time" do
      allow(vacancy).to receive(:working_patterns).and_return(%w[full_time part_time])

      expect(parsed.status_id).to eq(described_class::STATUS_FULL_TIME_ID)
    end

    it "returns the full time status id if the vacancy working patterns include term_time and exclude part_time" do
      allow(vacancy).to receive(:working_patterns).and_return(["term_time"])

      expect(parsed.status_id).to eq(described_class::STATUS_FULL_TIME_ID)
    end

    it "returns the part time status id if the vacancy working patterns include part_time" do
      allow(vacancy).to receive(:working_patterns).and_return(["part_time"])

      expect(parsed.status_id).to eq(described_class::STATUS_PART_TIME_ID)
    end

    it "returns the part time status id if the vacancy working patterns include term_time and part_time" do
      allow(vacancy).to receive(:working_patterns).and_return(%w[term_time part_time])

      expect(parsed.status_id).to eq(described_class::STATUS_PART_TIME_ID)
    end

    it "returns nil if the vacancy working patterns are blank" do
      allow(vacancy).to receive(:working_patterns).and_return([])

      expect(parsed.status_id).to be_nil
    end
  end

  describe "#type_id" do
    it "returns the permanent type id if the vacancy contract type is permanent" do
      allow(vacancy).to receive(:contract_type).and_return("permanent")

      expect(parsed.type_id).to eq(described_class::TYPE_PERMANENT_ID)
    end

    it "returns the contract type id if the vacancy contract type is fixed_term" do
      allow(vacancy).to receive(:contract_type).and_return("fixed_term")

      expect(parsed.type_id).to eq(described_class::TYPE_CONTRACT_ID)
    end

    it "returns the contract type id if the vacancy contract type is parental_leave_cover" do
      allow(vacancy).to receive(:contract_type).and_return("parental_leave_cover")

      expect(parsed.type_id).to eq(described_class::TYPE_CONTRACT_ID)
    end
  end
end
