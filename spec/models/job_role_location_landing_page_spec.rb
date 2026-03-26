require "rails_helper"

RSpec.describe JobRoleLocationLandingPage do
  subject(:landing_page) { described_class["teaching-assistant", "london"] }

  let(:search) { instance_double(Search::VacancySearch, total_count: 42) }

  before do
    allow(Search::VacancySearch)
      .to receive(:new)
      .with(hash_including(support_job_roles: %w[teaching_assistant], location: "London"))
      .and_return(search)
  end

  describe ".exists?" do
    it "returns true for a targeted job role and location combo" do
      expect(described_class.exists?("teaching-assistant", "london")).to be(true)
    end

    it "handles case-insensitive job role and location" do
      expect(described_class.exists?("Teaching-Assistant", "london")).to be(true)
      expect(described_class.exists?("TEACHING-ASSISTANT", "london")).to be(true)
      expect(described_class.exists?("teaching-assistant", "London")).to be(true)
      expect(described_class.exists?("teaching-assistant", "LONDON")).to be(true)
    end

    it "returns false for a valid job role not in the targeted list" do
      expect(described_class.exists?("teacher", "london")).to be(false)
    end

    it "returns false for a valid location not in the targeted list" do
      expect(described_class.exists?("teaching-assistant", "leeds")).to be(false)
    end

    it "returns false for a combo that does not exist in the targeted list" do
      expect(described_class.exists?("doctor", "hizzingford")).to be(false)
    end
  end

  describe ".[]" do
    it "returns a landing page instance for a targeted combo" do
      expect(landing_page.job_role).to eq("teaching_assistant")
      expect(landing_page.location).to eq("london")
      expect(landing_page.criteria).to eq({ support_job_roles: %w[teaching_assistant], location: "London" })
    end

    it "sets teaching_job_roles for teaching roles" do
      allow(Search::VacancySearch)
        .to receive(:new)
        .with(hash_including(teaching_job_roles: %w[sendco], location: "London"))
        .and_return(search)

      page = described_class["sendco", "london"]
      expect(page.criteria).to eq({ teaching_job_roles: %w[sendco], location: "London" })
    end

    it "raises an error if the combo is not in the targeted list" do
      expect { described_class["teacher", "london"] }
        .to raise_error("No such job role + location landing page: 'teacher' + 'london'")
    end
  end

  describe "#slug" do
    it "returns the correct slug format" do
      expect(landing_page.slug).to eq("teaching-assistant-jobs-in-london")
    end
  end

  describe "#location_name" do
    it "returns the titleized location name" do
      expect(landing_page.location_name).to eq("London")
    end

    it "handles mapped locations" do
      stub_const("MAPPED_LOCATIONS", { "london" => "Greater London" })
      expect(landing_page.location_name).to eq("Greater London")
    end
  end

  describe "#job_role_name" do
    it "returns the translated job role name" do
      expect(landing_page.job_role_name).to eq(I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.teaching_assistant"))
    end
  end

  describe "#count" do
    it "performs a search and returns its total count" do
      expect(landing_page.count).to eq(42)
    end
  end

  describe "i18n methods" do
    let(:job_role_name) { I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.teaching_assistant") }

    specify { expect(landing_page.heading).to eq(I18n.t("landing_pages._job_role_location.heading", location: "London", job_role: job_role_name.downcase, count: "<span class=\"govuk-!-font-weight-bold\">42</span>")) }
    specify { expect(landing_page.meta_description).to eq(I18n.t("landing_pages._job_role_location.meta_description", location: "London", job_role: job_role_name.downcase)) }
    specify { expect(landing_page.title).to eq(I18n.t("landing_pages._job_role_location.title", location: "London", job_role: job_role_name)) }
  end
end
