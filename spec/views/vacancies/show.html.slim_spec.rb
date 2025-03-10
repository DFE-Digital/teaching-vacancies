require "rails_helper"

RSpec.describe "vacancies/show" do
  before do
    assign :vacancy, VacancyPresenter.new(create(:vacancy, hourly_rate: hourly_rate, salary: salary))
    render
  end

  describe "job posting metadata" do
    let(:json_ld) { JSON.parse(rendered.html.css("script.jobref").inner_text, symbolize_names: true) }

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
end
