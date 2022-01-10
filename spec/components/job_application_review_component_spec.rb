require "rails_helper"

RSpec.describe JobApplicationReviewComponent, type: :component do
  subject(:component) { described_class.new(*args, **kwargs) }

  let(:args) { [job_application] }
  let(:kwargs) do
    {
      show_tracks:,
      step_process:,
    }
  end

  let(:job_application) { create(:job_application) }
  let(:show_tracks) { nil }
  let(:step_process) do
    Jobseekers::JobApplications::JobApplicationStepProcess.new(
      :review,
      job_application:,
    )
  end

  it_behaves_like ReviewComponent

  it "does not render a task list by default" do
    render_inline(component)
    expect(page).not_to have_css("ol.app-task-list")
  end

  context "if sections are provided" do
    before do
      component.section(:references)
      component.section(:declarations)
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

  context "if 'train tracks' are on" do
    let(:show_tracks) { true }

    it "renders the 'train tracks' component" do
      render_inline(component)
      expect(page).to have_css(".steps-component")
    end
  end

  context "if 'train tracks' are off" do
    let(:show_tracks) { false }

    it "does not render the 'train tracks' component" do
      render_inline(component)
      expect(page).not_to have_css(".steps-component")
    end
  end
end
