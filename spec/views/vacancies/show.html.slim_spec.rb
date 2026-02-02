require "rails_helper"

RSpec.describe "vacancies/show" do
  before do
    assign :vacancy, VacancyPresenter.new(vacancy)
    render
  end

  describe "job posting metadata" do
    let(:json_ld) { JSON.parse(rendered.html.css("script.jobref").inner_text, symbolize_names: true) }
    let(:vacancy) { create(:vacancy, hourly_rate: hourly_rate, salary: salary) }

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
    context "when vacancy is ect_suitable" do
      let(:vacancy) { create(:vacancy, ect_status: :ect_suitable) }

      it "renders the personal statement help section" do
        expect(rendered).to have_css(".sidebar-info-box")
        expect(rendered).to have_content(I18n.t("jobs.personal_statement_help.heading"))
      end
    end

    context "when vacancy is not ect_suitable" do
      let(:vacancy) { create(:vacancy, ect_status: :ect_unsuitable) }

      it "does not render the personal statement help section" do
        expect(rendered).not_to have_css(".sidebar-info-box")
        expect(rendered).not_to have_content(I18n.t("jobs.personal_statement_help.heading"))
      end
    end
  end
end
