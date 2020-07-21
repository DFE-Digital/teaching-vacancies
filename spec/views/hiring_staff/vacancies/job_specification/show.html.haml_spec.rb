require 'rails_helper'

RSpec.describe 'hiring_staff/vacancies/job_specification/show' do
  around do |example|
    # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
    # environment.
    # rubocop:disable Rails/HttpPositionalArguments
    Rails.application.routes.draw do
      get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step 1 title' }
      get :job_specification_organisation_job, to: 'job#step_two',
                                               defaults: { create_step: 2, step_title: 'Step 2 title' }
      get :step_two_a, to: 'job#step_three_a', defaults: { create_step: 3, step_title: 'Step 3a title' }
      get :step_two_b, to: 'job#step_three_b', defaults: { create_step: 3, step_title: 'Step 3b title' }
    end
    # rubocop:enable Rails/HttpPositionalArguments

    # Without the `without_partial_double_verification` wrapper the `:current_school` stub with fail and raise the
    # exception that the view does not implement `:current_school`.
    without_partial_double_verification { example.run }

    Rails.application.routes_reloader.reload!
  end

  before do
    allow(view).to receive(:current_organisation).and_return(instance_double(School).as_null_object)
    # Configured via the params set on the routes, as shown above. Exposed using a helper method, but that isn't
    # important for *this* test.
    allow(view).to receive(:params).and_return({ create_step: 2 })
    assign(:form, JobSpecificationForm.new)
    assign(:form_submission_url_method, 'post')
    assign(:form_submission_url, job_specification_organisation_job_path)
    render
  end

  context 'for SchoolGroup-level users' do
    before { allow(session).to receive(:[]).with(:uid).and_return ('1234') }

    it 'shows the correct number of steps as calculated from routes' do
      expect(render).to match(/Step \d of 3/)
    end

    it 'shows the current step to the user' do
      expect(render).to match(/Step 2 of \d/)
    end
  end

  context 'for School-level users' do
    it 'shows the correct number of steps as calculated from routes' do
      expect(render).to match(/Step \d of 2/)
    end

    it 'shows the current step to the user' do
      expect(render).to match(/Step 1 of \d/)
    end
  end
end
