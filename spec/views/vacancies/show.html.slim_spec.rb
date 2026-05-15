require "rails_helper"

RSpec.describe "vacancies/show" do
  before do
    if jobseeker.present?
      sign_in(jobseeker, scope: :jobseeker)
      allow(view).to receive_messages(current_jobseeker: jobseeker)
    end
    assign :vacancy, vacancy.decorate
    render
  end

  after { sign_out jobseeker if jobseeker.present? }

  describe "job posting metadata" do
    let(:jobseeker) { nil }
    let(:json_ld) { JSON.parse(rendered.html.css("script.jobref").inner_text, symbolize_names: true) }
    let(:vacancy) { build_stubbed(:vacancy, hourly_rate: hourly_rate, salary: salary) }

    context "with hourly rate" do
      let(:hourly_rate) { 25 }
      let(:salary) { "27000" }

      it "has hourly rate as salary" do
        expect(json_ld.fetch(:baseSalary)).to eq({ :@type => "MonetaryAmount", :currency => "GBP", :value => { :@type => "QuantitativeValue", :unitText => "HOUR", :value => "25" } })
      end
    end

    context "without hourly rate" do
      let(:hourly_rate) { nil }
      let(:salary) { "27000" }

      it "has salary instead" do
        expect(json_ld.fetch(:baseSalary)).to eq({ :@type => "MonetaryAmount", :currency => "GBP", :value => { :@type => "QuantitativeValue", :unitText => "YEAR", :value => "27000" } })
      end
    end

    context "without money" do
      let(:hourly_rate) { nil }
      let(:salary) { nil }

      it "has no salary" do
        expect(json_ld.key?(:baseSalary)).to be(false)
      end
    end
  end

  describe "personal statement help" do
    let(:jobseeker) { nil }

    context "when vacancy is ect_suitable but does not have enable_job_applications" do
      let(:vacancy) { build_stubbed(:vacancy, ect_status: :ect_suitable, enable_job_applications: false) }

      it "renders the personal statement help section" do
        expect(rendered).to have_css(".sidebar-info-box")
        expect(rendered).to have_content(I18n.t("jobs.personal_statement_help.heading"))
      end
    end

    context "when vacancy has enable_job_applications but is not ect_suitable" do
      let(:vacancy) { build_stubbed(:vacancy, ect_status: :ect_unsuitable, enable_job_applications: true) }

      it "renders the personal statement help section" do
        expect(rendered).to have_css(".sidebar-info-box")
        expect(rendered).to have_content(I18n.t("jobs.personal_statement_help.heading"))
      end
    end

    context "when vacancy is ect_suitable and has enable_job_applications" do
      let(:vacancy) { build_stubbed(:vacancy, ect_status: :ect_suitable, enable_job_applications: true) }

      it "renders the personal statement help section" do
        expect(rendered).to have_css(".sidebar-info-box")
        expect(rendered).to have_content(I18n.t("jobs.personal_statement_help.heading"))
      end
    end

    context "when vacancy is not ect_suitable and does not have enable_job_applications" do
      let(:vacancy) { build_stubbed(:vacancy, ect_status: :ect_unsuitable, enable_job_applications: false) }

      it "does not render the personal statement help section" do
        expect(rendered).to have_no_css(".sidebar-info-box")
        expect(rendered).to have_no_content(I18n.t("jobs.personal_statement_help.heading"))
      end
    end
  end

  context "with a website vacancy" do
    let(:expected_link) { I18n.t("jobs.view_advert.school", href: "http://www.google.com") }
    let(:jobseeker) { nil }

    context "with a published vacancy" do
      let(:vacancy) do
        build_stubbed(:vacancy, :apply_via_website,
                      application_link: "www.google.com", organisations: [build(:school)])
      end

      it "has an application link" do
        expect(rendered).to have_link(expected_link)
      end
    end

    context "with an expired vacancy" do
      let(:vacancy) do
        build_stubbed(:vacancy, :expired, :apply_via_website,
                      application_link: "www.google.com", organisations: [build(:school)])
      end

      it "does not have an application link" do
        expect(rendered).to have_no_link(expected_link)
      end
    end
  end

  context "with a download form vacancy" do
    let(:vacancy) do
      create(:vacancy, :with_application_form,
             organisations: [build(:school)])
    end
    let(:jobseeker) { nil }
    let(:expected_content) { "Download an application form" }

    it "apply link can only be found after login" do
      expect(rendered).to have_no_content(expected_content)
    end

    context "when signed in" do
      let(:jobseeker) { build_stubbed(:jobseeker) }

      it "apply link can only be found after login" do
        expect(rendered).to have_content(expected_content)
      end
    end
  end

  context "when a school has geocoding" do
    let(:jobseeker) { nil }
    let(:vacancy) { build_stubbed(:vacancy, organisations: [school]) }

    let(:school) { build_stubbed(:school, geopoint: "POINT(51.4788757883318 0.0253328559417984)") }

    it "displays a map" do
      expect(rendered).to have_css("div#map")
    end
  end

  context "when a school has no geocoding" do
    let(:jobseeker) { nil }
    let(:vacancy) { build_stubbed(:vacancy, organisations: [school]) }
    let(:school) { build_stubbed(:school, geopoint: nil) }

    it "does not display a map" do
      expect(rendered).to have_no_css("div#map")
    end
  end
end
