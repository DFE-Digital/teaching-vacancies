require "rails_helper"

RSpec.describe VacancySelectorComponent, type: :component do
  let(:organisation) { create(:school) }
  let(:vacancies) do
    create_list(:vacancy, vacancy_count, organisations: [organisation])
  end

  let(:vacancy_count) { 1 }
  let(:label_text) { "A label" }

  let(:args) { [vacancies] }
  let(:kwargs) do
    {
      label_text:,
      organisation:,
    }
  end

  before do
    create(:vacancy, organisations: [organisation], status: :draft)
  end

  describe "the rendered component" do
    subject! { render_inline(described_class.new(*args, **kwargs)) }

    it_behaves_like "a component that accepts custom classes", uses_positional_args: true
    it_behaves_like "a component that accepts custom HTML attributes", uses_positional_args: true

    context "if there are 20 or fewer published vacancies" do
      let(:vacancy_count) { 20 }

      scenario "the listings are shown as a set of radio buttons" do
        expect(page).to have_css(".govuk-radios__input", count: vacancy_count)
      end
    end
  end
end
