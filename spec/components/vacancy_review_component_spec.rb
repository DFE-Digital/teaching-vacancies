require "rails_helper"

RSpec.describe VacancyReviewComponent, type: :component do
  subject(:component) { described_class.new(*args, **kwargs) }

  let(:args) { [vacancy] }
  let(:kwargs) do
    {
      back_to: back_to,
      step_process: step_process,
    }
  end

  let(:vacancy) { create(:vacancy, organisations: [school]) }
  let(:school) { create(:school) }
  let(:back_to) { "review" }
  let(:step_process) do
    Publishers::Vacancies::VacancyStepProcess.new(
      :review,
      vacancy: vacancy,
      organisation: school,
    )
  end

  it_behaves_like ReviewComponent

  it "does not render a task list by default" do
    render_inline(component)
    expect(page).not_to have_css("ol.app-task-list")
  end

  context "if sections are provided" do
    before do
      component.section(:job_details)
      component.section(:working_patterns)
      component.above { "<p id='above'>Above</p>".html_safe }
      component.below { "<p id='below'>Below</p>".html_safe }

      render_inline(component)
    end

    it "renders each section as part of a task list, between 'above' and 'below'" do
      expect(page).to have_css("ol.app-task-list")
      expect(page).to have_css("ol.app-task-list li", count: 2)
      expect(page).to have_css("p#above + ol.app-task-list")
      expect(page).to have_css("ol.app-task-list + p#below")
    end
  end

  context "if the vacancy is published" do
    let(:vacancy) { create(:vacancy, :published) }

    it "does not render the 'train tracks' component" do
      render_inline(component)
      expect(page).not_to have_css(".steps-component")
    end
  end

  context "if the vacancy is unpublished" do
    let(:vacancy) { create(:vacancy, :draft) }

    it "renders the 'train tracks' component" do
      render_inline(component)
      expect(page).to have_css(".steps-component")
    end
  end
end
