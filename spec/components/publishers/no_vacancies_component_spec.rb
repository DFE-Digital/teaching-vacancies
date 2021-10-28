require "rails_helper"

RSpec.describe Publishers::NoVacanciesComponent, type: :component do
  let(:organisation) { build(:school) }
  let(:email) { "publisher@example.net" }

  before do
    allow(Vacancy).to receive_message_chain(:in_organisation_ids, :active, :none?).and_return(no_vacancies)
    render_inline(described_class.new(organisation: organisation, email: email))
  end

  context "when organisation has active vacancies" do
    let(:no_vacancies) { false }

    it "does not render the no vacancies component" do
      expect(rendered_component).to be_blank
    end
  end

  context "when organisation has no active vacancies" do
    let(:no_vacancies) { true }

    it "renders the no vacancies component" do
      expect(rendered_component).to include(I18n.t("publishers.no_vacancies_component.heading"))
    end
  end
end
