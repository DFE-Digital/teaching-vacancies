module Jobseekers
  class Profiles::QualifiedTeacherStatusController < ProfilesController
    def edit
      @form = Profile::QualifiedTeacherStatusForm.new(profile.slice(*(form_class.fields)))
    end

    def update
      @form = Profile::QualifiedTeacherStatusForm.new(form_params)
      if @form.valid?
        profile.update!(form_params)
        redirect_to jobseekers_profile_qualified_teacher_status_path
      else
        render :edit
      end
    end

    private

    def form_class
      Profile::QualifiedTeacherStatusForm
    end

    def form_params
      params.require(:jobseekers_profile_qualified_teacher_status_form).permit(form_class.fields)
    end
  end
end
