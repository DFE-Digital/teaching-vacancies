module Jobseekers::Wizardable
  STEPS = {
    personal_details: 1,
    personal_statement: 5,
  }.freeze

  FORMS = {
    personal_details: Jobseekers::JobApplication::PersonalDetailsForm,
    personal_statement: Jobseekers::JobApplication::PersonalStatementForm,
  }.freeze

  FORM_PARAMS = {
    personal_details: :personal_details_params,
    personal_statement: :personal_statement_params,
  }.freeze

  def personal_details_params(params)
    ParameterSanitiser.call(params).require(:jobseekers_job_application_personal_details_form).permit(:first_name)
  end

  def personal_statement_params(params)
    ParameterSanitiser.call(params)
                      .require(:jobseekers_job_application_personal_statement_form).permit(:personal_statement)
  end
end
