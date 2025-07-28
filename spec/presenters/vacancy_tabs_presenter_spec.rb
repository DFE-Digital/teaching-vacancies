require "rails_helper"

RSpec.describe VacancyTabsPresenter do
  describe "all job application statuses except draft are listed" do
    subject { described_class::TABS_DEFINITION.values.flatten }

    it { is_expected.to match_array(JobApplication.statuses.except(:draft).keys) }
  end

  describe "tabs_data" do
    subject(:tabs_data) { described_class.tabs_data(vacancy) }

    let(:vacancy) { create(:vacancy, job_applications:) }
    let(:job_applications) { submitted + reviewed + unsuccessful + withdrawn + shortlisted + interviewing + offered + declined }

    JobApplication.statuses.except(:draft).each_key do |status|
      let(status.to_sym) { create_list(:job_application, 2, :"status_#{status}") }
    end

    it "returns tabs names" do
      expect(tabs_data.keys).to match_array(%w[submitted unsuccessful shortlisted interviewing offered])
    end

    it "contains all job application for tab submitted" do
      expect(tabs_data["submitted"].count).to eq(4)
      expect(tabs_data["submitted"].map(&:status).uniq).to match_array(%w[submitted reviewed])
    end

    it "contains all job application for tab unsuccessful" do
      expect(tabs_data["unsuccessful"].count).to eq(4)
      expect(tabs_data["unsuccessful"].map(&:status).uniq).to match_array(%w[unsuccessful withdrawn])
    end

    it "contains all job application for tab shortlisted" do
      expect(tabs_data["shortlisted"].count).to eq(2)
      expect(tabs_data["shortlisted"].map(&:status).uniq).to match_array(%w[shortlisted])
    end

    it "contains all job application for tab interviewing" do
      expect(tabs_data["interviewing"].count).to eq(2)
      expect(tabs_data["interviewing"].map(&:status).uniq).to match_array(%w[interviewing])
    end

    it "contains all job application for tab offered" do
      expect(tabs_data["offered"].count).to eq(4)
      expect(tabs_data["offered"].map(&:status).uniq).to match_array(%w[offered declined])
    end
  end
end
