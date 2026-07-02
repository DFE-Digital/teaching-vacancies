require "rails_helper"

RSpec.describe "publishers/vacancies/vacancy_review_sections/_about_the_role" do
  before { render partial: "publishers/vacancies/vacancy_review_sections/about_the_role", locals: { vacancy: vacancy.decorate } }

  context "when published with documents" do
    # TODO: can't currently stub a vacancy with documents
    let(:vacancy) { create(:vacancy, :with_supporting_documents) }

    it "shows documents" do
      expect(rendered).to have_content(I18n.t("jobs.additional_documents"))
    end
  end
end
