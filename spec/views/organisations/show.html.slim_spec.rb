require "rails_helper"

RSpec.describe "organisations/show", type: :view do
  before do
    assign :organisation, create(:school, vacancies: [vacancy])
    render
  end

  context "with salary" do
    let(:vacancy) { build(:vacancy, :without_any_money, salary: Faker::Alphanumeric.alpha(number: 7)) }

    it "shows salary" do
      expect(rendered).to have_content(vacancy.salary)
    end
  end

  context "with actual salary" do
    let(:vacancy) { build(:vacancy, :without_any_money, actual_salary: Faker::Number.number(digits: 5)) }

    it "shows actual salary" do
      expect(rendered).to have_content(vacancy.actual_salary)
    end
  end

  context "with hourly rate" do
    let(:vacancy) { build(:vacancy, :without_any_money, hourly_rate: Faker::Alphanumeric.alpha(number: 7)) }

    it "shows hourly rate" do
      expect(rendered).to have_content(vacancy.hourly_rate)
    end
  end

  context "with pay scale" do
    let(:vacancy) { build(:vacancy, :without_any_money, pay_scale: Faker::Alphanumeric.alpha(number: 7)) }

    it "shows pay scale" do
      expect(rendered).to have_content(vacancy.pay_scale)
    end
  end

  context "with all" do
    let(:vacancy) { build(:vacancy) }

    it "shows salary" do
      expect(rendered).to have_content(vacancy.salary)
    end

    it "shows actual salary" do
      expect(rendered).to have_content(vacancy.actual_salary)
    end

    it "shows hourly rate" do
      expect(rendered).to have_content(vacancy.hourly_rate)
    end

    it "shows pay scale" do
      expect(rendered).to have_content(vacancy.pay_scale)
    end
  end
end
