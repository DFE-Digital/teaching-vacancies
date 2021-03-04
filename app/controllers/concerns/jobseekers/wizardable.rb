module Jobseekers::Wizardable
  FORMS = {
    personal_details: Jobseekers::JobApplication::PersonalDetailsForm,
    professional_status: Jobseekers::JobApplication::ProfessionalStatusForm,
    employment_history: Jobseekers::JobApplication::EmploymentHistoryForm,
    personal_statement: Jobseekers::JobApplication::PersonalStatementForm,
    references: Jobseekers::JobApplication::ReferencesForm,
    equal_opportunities: Jobseekers::JobApplication::EqualOpportunitiesForm,
    ask_for_support: Jobseekers::JobApplication::AskForSupportForm,
    declarations: Jobseekers::JobApplication::DeclarationsForm,
  }.freeze

  FORM_PARAMS = {
    personal_details: :personal_details_params,
    professional_status: :professional_status_params,
    employment_history: :employment_history_params,
    personal_statement: :personal_statement_params,
    references: :references_params,
    equal_opportunities: :equal_opportunities_params,
    ask_for_support: :ask_for_support_params,
    declarations: :declarations_params,
  }.freeze

  def steps_config
    {
      personal_details: { number: 1, title: t(".personal_details.heading") },
      professional_status: { number: 3, title: t(".professional_status.heading") },
      employment_history: { number: 4, title: t(".employment_history.heading") },
      personal_statement: { number: 5, title: t(".personal_statement.heading") },
      references: { number: 6, title: t(".references.heading") },
      equal_opportunities: { number: 7, title: t(".equal_opportunities.heading") },
      ask_for_support: { number: 8, title: t(".ask_for_support.heading") },
      declarations: { number: 9, title: t(".declarations.heading") },
    }.freeze
  end

  def personal_details_params(params)
    params.require(:jobseekers_job_application_personal_details_form)
          .permit(:building_and_street, :email_address, :first_name, :last_name, :national_insurance_number,
                  :phone_number, :previous_names, :postcode, :teacher_reference_number, :town_or_city)
  end

  def professional_status_params(params)
    params.require(:jobseekers_job_application_professional_status_form)
          .permit(:qualified_teacher_status, :qualified_teacher_status_year,
                  :no_qualified_teacher_status_details, :statutory_induction_complete)
  end

  def employment_history_params(params)
    params.require(:jobseekers_job_application_employment_history_form)
          .permit(:gaps_in_employment, :gaps_in_employment_details)
  end

  def personal_statement_params(params)
    params.require(:jobseekers_job_application_personal_statement_form)
          .permit(:personal_statement)
  end

  def references_params(_params)
    {}
  end

  def equal_opportunities_params(params)
    params.require(:jobseekers_job_application_equal_opportunities_form)
          .permit(:disability, :gender, :gender_description, :orientation, :orientation_description,
                  :ethnicity, :ethnicity_description, :religion, :religion_description)
  end

  def ask_for_support_params(params)
    params.require(:jobseekers_job_application_ask_for_support_form)
          .permit(:support_needed, :support_details)
  end

  def declarations_params(params)
    params.require(:jobseekers_job_application_declarations_form)
          .permit(:banned_or_disqualified, :close_relationships, :close_relationships_details, :right_to_work_in_uk)
  end

  def employment_history_info
    @employment_history_info ||= [
      { attribute: "organisation", title: t("jobseekers.job_applications.employment_history.organisation") },
      { attribute: "salary", title: t("jobseekers.job_applications.employment_history.salary") },
      { attribute: "subjects", title: t("jobseekers.job_applications.employment_history.subjects") },
      { attribute: "started_on", title: t("jobseekers.job_applications.employment_history.started_on"), date: true },
      { attribute: "current_role", title: t("jobseekers.job_applications.employment_history.current_role") },
      { attribute: "ended_on", title: t("jobseekers.job_applications.employment_history.ended_on"), date: true },
      { attribute: "reason_for_leaving", title: t("jobseekers.job_applications.employment_history.reason_for_leaving") },
      { attribute: "main_duties", title: t("jobseekers.job_applications.employment_history.main_duties") },
    ]
  end

  def reference_info
    @reference_info ||= [
      { attribute: "job_title", title: t("jobseekers.job_applications.references.job_title") },
      { attribute: "organisation", title: t("jobseekers.job_applications.references.organisation") },
      { attribute: "relationship_to_applicant", title: t("jobseekers.job_applications.references.relationship_to_applicant") },
      { attribute: "email_address", title: t("jobseekers.job_applications.references.email_address") },
      { attribute: "phone_number", title: t("jobseekers.job_applications.references.phone_number") },
    ]
  end
end
