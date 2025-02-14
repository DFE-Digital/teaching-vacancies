module Jobseekers
  class Profiles::QualifiedTeacherStatusController < ProfilesController
    def edit
      @form = Profile::QualifiedTeacherStatusForm.new(profile.slice(*(form_class.fields - %i[qualified_teacher_status_details])))
    end

    def update
      @form = Profile::QualifiedTeacherStatusForm.new(form_params)
      if @form.valid?
        year = @form.qualified_teacher_status == "yes" ? @form.qualified_teacher_status_year : ""
        profile.update(qualified_teacher_status: JobseekerProfile.qualified_teacher_statuses[@form.qualified_teacher_status],
                       qualified_teacher_status_year: year,
                       teacher_reference_number: @form.updated_teacher_reference_number,
                       statutory_induction_complete: @form.statutory_induction_complete,
                       qts_age_range_and_subject: @form.qts_age_range_and_subject,
                       has_teacher_reference_number: @form.has_teacher_reference_number,
                       statutory_induction_complete_details: @form.statutory_induction_complete_details)
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
