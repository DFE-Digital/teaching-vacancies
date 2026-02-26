module Jobseekers::Profiles
  class PersonalDetailsController < Jobseekers::BaseController
    include Wicked::Wizard

    steps(*PersonalDetailsForm::FORMS.keys)

    helper_method :escape_path, :back_url

    before_action :set_personal_details_record

    def show
      @form = form_class.new(@personal_details_record.slice(form_class.fields))
      render_wizard nil, params: { back_to_review: params[:back_to_review] }
    end

    def update
      @form = form_class.new(params.fetch(form_key, {}).permit(*form_class.fields))
      if @form.valid?
        @personal_details_record.update!(@form.params_to_save.merge(completed_steps: @personal_details_record.completed_steps.merge(step => :completed)))
        if params[:back_to_review]
          redirect_to review_jobseekers_profile_personal_details_steps_path
        elsif next_step == Wicked::FINISH_STEP
          redirect_to finish_wizard_path
        else
          redirect_to next_wizard_path
        end
      else
        render_wizard
      end
    end

    def finish_wizard_path
      review_jobseekers_profile_personal_details_steps_path
    end

    private

    def back_url
      previous_wizard_path
    end

    def form_key
      ActiveModel::Naming.param_key(form_class)
    end

    def escape_path
      jobseekers_profile_path
    end

    def form_class
      PersonalDetailsForm::FORMS.fetch(step)
    end

    def set_personal_details_record
      @personal_details_record = current_jobseeker.jobseeker_profile.personal_details || current_jobseeker.jobseeker_profile.build_personal_details
    end
  end
end
