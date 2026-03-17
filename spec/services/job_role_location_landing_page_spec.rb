require "rails_helper"

RSpec.describe JobRoleLocationLandingPage do
  subject(:landing_page) { described_class["teacher", "birmingham"] }

  let(:search) { instance_double(Search::VacancySearch, total_count: 42) }

  before do
    create(:location_polygon, name: "birmingham")

    allow(Search::VacancySearch)
      .to receive(:new)
      .with(hash_including(teaching_job_roles: %w[teacher], location: "Birmingham"))
      .and_return(search)
  end

  describe ".exists?" do
    it "returns true when both job role exists and location polygon exists" do
      expect(described_class.exists?("teacher", "birmingham")).to be(true)
    end

    it "handles case-insensitive job role and location" do
      expect(described_class.exists?("Teacher", "birmingham")).to be(true)
      expect(described_class.exists?("TEACHER", "birmingham")).to be(true)
      expect(described_class.exists?("teacher", "Birmingham")).to be(true)
      expect(described_class.exists?("teacher", "BIRMINGHAM")).to be(true)
    end

    it "returns false when job role doesn't exist" do
      expect(described_class.exists?("doctor", "birmingham")).to be(false)
    end

    it "returns false when location polygon doesn't exist" do
      expect(described_class.exists?("teacher", "hizzingford")).to be(false)
    end
  end

  describe ".[]" do
    it "returns a landing page instance when both job role and location exist" do
      expect(landing_page.job_role).to eq("teacher")
      expect(landing_page.location).to eq("birmingham")
      expect(landing_page.criteria).to eq({ teaching_job_roles: %w[teacher], location: "Birmingham" })
    end

    it "sets support_job_roles for support roles" do
      page = described_class["teaching-assistant", "birmingham"]
      expect(page.criteria).to eq({ support_job_roles: %w[teaching_assistant], location: "Birmingham" })
    end

    it "raises an error if job role or location doesn't exist" do
      expect { described_class["wizard", "birmingham"] }
        .to raise_error("No such job role + location landing page: 'wizard' + 'birmingham'")
    end
  end

  describe "#slug" do
    it "returns the correct slug format" do
      expect(landing_page.slug).to eq("teacher-jobs-in-birmingham")
    end
  end

  describe "#location_name" do
    it "returns the titleized location name" do
      expect(landing_page.location_name).to eq("Birmingham")
    end

    it "handles mapped locations" do
      stub_const("MAPPED_LOCATIONS", { "brum" => "birmingham" })
      page = described_class["teacher", "brum"]
      expect(page.location_name).to eq("Birmingham")
    end

    it "handles 'and' in location names" do
      create(:location_polygon, name: "bath and north east somerset")
      page = described_class["teacher", "bath-and-north-east-somerset"]
      expect(page.location_name).to eq("Bath and North East Somerset")
    end
  end

  describe "#job_role_name" do
    it "returns the translated job role name" do
      expect(landing_page.job_role_name).to eq(I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.teacher"))
    end
  end

  describe "#count" do
    it "performs a search and returns its total count" do
      expect(landing_page.count).to eq(42)
    end
  end

  describe "i18n methods" do
    let(:job_role_name) { I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.teacher") }

    specify { expect(landing_page.heading).to eq(I18n.t("landing_pages._job_role_location.heading", location: "Birmingham", job_role: job_role_name.downcase, count: "<span class=\"govuk-!-font-weight-bold\">42</span>")) }
    specify { expect(landing_page.meta_description).to eq(I18n.t("landing_pages._job_role_location.meta_description", location: "Birmingham", job_role: job_role_name.downcase)) }
    specify { expect(landing_page.title).to eq(I18n.t("landing_pages._job_role_location.title", location: "Birmingham", job_role: job_role_name)) }
  end
end
