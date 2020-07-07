require 'rails_helper'

RSpec.describe 'hiring_staff/vacancies/job_specification/show' do
  around do |example|
    # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
    # environment.
    # rubocop:disable Rails/HttpPositionalArguments
    Rails.application.routes.draw do
      get :job_specification_organisation_job, to: 'dummy#step_one',
                                               defaults: { create_step: 1, step_title: 'Step 1 title' }
      get :step_two, to: 'job#step_one', defaults: { create_step: 2, step_title: 'Step 2 title' }
    end
    # rubocop:enable Rails/HttpPositionalArguments

    # Without the `without_partial_double_verification` wrapper the `:current_school` stub with fail and raise the
    # exception that the view does not implement `:current_school`.
    without_partial_double_verification { example.run }

    Rails.application.routes_reloader.reload!
  end

  before do
    allow(view).to receive(:current_school).and_return(instance_double(School).as_null_object)
    # Configured via the params set on the routes, as shown above. Exposed using a helper method, but that isn't
    # important for *this* test.
    allow(view).to receive(:params).and_return({ create_step: 1 })
    assign(:job_specification_form, JobSpecificationForm.new)
    assign(:job_specification_url_method, 'post')
    assign(:job_specification_url, job_specification_organisation_job_path(school_id: 'school_id'))
    render
  end

  it 'shows the correct number of steps as calculated from routes' do
    expect(render).to match(/Step \d of 2/)
  end

  it 'shows the current step to the user' do
    expect(render).to match(/Step 1 of \d/)
  end
end
