module Jobseekers::Profiles
  class JobPreferencesController < Jobseekers::BaseController
    include Wicked::Wizard

    steps(*Jobseekers::JobPreferencesForm::FORMS.keys)

    helper_method :escape_path

    before_action :set_model, only: %i[show update]
    before_action :load_show_form, only: [:show]
    before_action :force_location_added, only: [:show], if: -> { step == :locations && @model.locations.empty? }

    def show
      if @form.skip?(@model)
        @model.update!(completed_steps: @model.completed_steps.merge(step => :skipped))
        skip_step
      end
      render_wizard nil, params: { back_to_review: params[:back_to_review] }
    end

    def update
      @form = form_class.new(params.fetch(form_key, {}).permit(*form_class.fields))
      if @form.valid?
        @model.update!(@form.params_to_save.merge(completed_steps: @model.completed_steps.merge(step => :completed)))
        if params[:back_to_review]
          redirect_to review_jobseekers_job_preferences_steps_path
        else
          redirect_to wizard_path Jobseekers::JobPreferencesForm.new(@model).next_invalid_step
        end
      else
        render_wizard
      end
    end

    def escape_path
      jobseekers_profile_path
    end

    def review
      @profile = current_jobseeker.jobseeker_profile
    end

    private

    def set_model
      @model = current_jobseeker.jobseeker_profile.job_preferences || current_jobseeker.jobseeker_profile.build_job_preferences
    end

    def load_show_form
      @form = form_class.new(@model.slice(form_class.field_names))
    end

    def form_class
      Jobseekers::JobPreferencesForm::FORMS.fetch(step)
    end

    def form_key
      ActiveModel::Naming.param_key(form_class)
    end

    def force_location_added
      redirect_to new_jobseekers_job_preferences_location_path
    end
  end
end
