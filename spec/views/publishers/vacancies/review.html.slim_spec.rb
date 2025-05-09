require "rails_helper"

RSpec.describe "publishers/vacancies/review" do
  let(:school) { build(:school) }
  let(:vacancy) { create(:vacancy, publish_on: publish_date) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }
  let(:step_process) { Publishers::Vacancies::VacancyStepProcess.new(:review, vacancy: vacancy, organisation: school) }

  before do
    vp = vacancy_presenter
    s = school
    sp = step_process

    view.define_singleton_method(:vacancy) { vp }
    view.define_singleton_method(:current_organisation) { s }
    view.define_singleton_method(:step_process) { sp }

    render
  end

  context "when the vacancy is published today" do
    let(:publish_date) { Date.current }

    it "shows the immediate publish button" do
      expect(rendered).to include(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
    end
  end

  context "when the vacancy is scheduled for future" do
    let(:publish_date) { Date.current + 2.days }

    it "shows the scheduled publish button" do
      expect(rendered).to include(I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft"))
    end
  end
end
