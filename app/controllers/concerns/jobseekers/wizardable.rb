module Jobseekers::Wizardable
  STEPS = {
    personal_details: 1,
    professional_status: 3,
    personal_statement: 5,
    declarations: 9,
  }.freeze

  FORMS = {
    personal_details: Jobseekers::JobApplication::PersonalDetailsForm,
    professional_status: Jobseekers::JobApplication::ProfessionalStatusForm,
    personal_statement: Jobseekers::JobApplication::PersonalStatementForm,
    declarations: Jobseekers::JobApplication::DeclarationsForm,
  }.freeze

  FORM_PARAMS = {
    personal_details: :personal_details_params,
    professional_status: :professional_status_params,
    personal_statement: :personal_statement_params,
    declarations: :declarations_params,
  }.freeze

  def personal_details_params(params)
    ParameterSanitiser.call(params)
                      .require(:jobseekers_job_application_personal_details_form)
                      .permit(:first_name)
  end

  def professional_status_params(params)
    ParameterSanitiser.call(params)
                      .require(:jobseekers_job_application_professional_status_form)
                      .permit(:qualified_teacher_status, :qualified_teacher_status_year, :statutory_induction_complete)
  end

  def personal_statement_params(params)
    ParameterSanitiser.call(params)
                      .require(:jobseekers_job_application_personal_statement_form)
                      .permit(:personal_statement)
  end

  def declarations_params(params)
    ParameterSanitiser.call(params)
                      .require(:jobseekers_job_application_declarations_form)
                      .permit(:banned_or_disqualified, :close_relationships, :close_relationships_details, :right_to_work_in_uk)
  end
end
