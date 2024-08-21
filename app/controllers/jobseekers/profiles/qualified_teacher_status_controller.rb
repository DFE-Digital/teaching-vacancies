class Jobseekers::Profiles::QualifiedTeacherStatusController < Jobseekers::ProfilesController
  def edit; end

  def update
    if form.valid?
      year = form.qualified_teacher_status == "yes" ? form.qualified_teacher_status_year : ""
      profile.update(qualified_teacher_status: JobseekerProfile.qualified_teacher_statuses[form.qualified_teacher_status],
                     qualified_teacher_status_year: year,
                     teacher_reference_number: form.teacher_reference_number,
                     statutory_induction_complete: form.statutory_induction_complete)
      redirect_to jobseekers_profile_qualified_teacher_status_path
    else
      render :edit
    end
  end

  private

  helper_method :form

  def form
    @form ||= Jobseekers::Profile::QualifiedTeacherStatusForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "edit"
      profile.slice(:qualified_teacher_status, :qualified_teacher_status_year, :teacher_reference_number, :statutory_induction_complete)
    when "update"
      form_params
    end
  end

  def form_class
    "jobseekers/profile/qualified_teacher_status_form".camelize.constantize
  end

  def form_params
    params.require(:jobseekers_profile_qualified_teacher_status_form).permit(form_class.fields)
  end
end
