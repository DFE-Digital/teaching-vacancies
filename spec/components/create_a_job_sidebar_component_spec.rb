require 'rails_helper'

RSpec.describe CreateAJobSidebarComponent, type: :component do
  let(:vacancy) { create(:vacancy, completed_step: completed_step) }
  let(:completed_step) { 0 }
  let(:current_step) { 1 }
  let(:school_group_user?) { true }

  before do
    allow_any_instance_of(HiringStaff::JobCreationHelper).to receive(:current_step).and_return(current_step)
    allow_any_instance_of(HiringStaff::JobCreationHelper).to receive(:school_group_user?).and_return(school_group_user?)
  end

  let!(:inline_component) { render_inline(described_class.new(vacancy: vacancy)) }

  it 'renders the sidebar' do
    expect(rendered_component).to include('Create a job listing steps')
  end

  it 'renders the job details step' do
    expect(rendered_component).to include(I18n.t('jobs.job_details'))
  end

  it 'renders the pay package step' do
    expect(rendered_component).to include(I18n.t('jobs.pay_package'))
  end

  it 'renders the important dates step' do
    expect(rendered_component).to include(I18n.t('jobs.important_dates'))
  end

  it 'renders the supporting documents step' do
    expect(rendered_component).to include(I18n.t('jobs.supporting_documents'))
  end

  it 'renders the application details step' do
    expect(rendered_component).to include(I18n.t('jobs.application_details'))
  end

  it 'renders the job summary step' do
    expect(rendered_component).to include(I18n.t('jobs.job_summary'))
  end

  it 'renders the review step' do
    expect(rendered_component).to include(I18n.t('jobs.review_heading'))
  end

  context 'when a School user creates a job' do
    let(:school_group_user?) { false }

    it 'does not render the job location step' do
      expect(rendered_component).not_to include(I18n.t('jobs.job_location'))
    end
  end

  context 'when a SchoolGroup user creates a job' do
    it 'renders the job location step' do
      expect(rendered_component).to include(I18n.t('jobs.job_location'))
    end
  end

  context 'when a step is active' do
    let(:component_active_step) do
      inline_component.css('.app-step-nav__step--active .app-step-nav__circle-background').to_html
    end

    it 'renders active class on current_step' do
      expect(component_active_step).to include(current_step.to_s)
    end
  end

  context 'when a step is completed' do
    let(:completed_step) { 1 }
    let(:current_step) { 2 }
    let(:component_completed_step) do
      inline_component.css('.app-step-nav__step--visited .app-step-nav__circle-background').to_html
    end

    it 'renders visited class on completed steps' do
      expect(component_completed_step).to include(component_completed_step.to_s)
    end
  end
end
