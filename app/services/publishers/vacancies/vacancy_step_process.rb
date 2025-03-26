class Publishers::Vacancies::VacancyStepProcess < DfE::Wizard::Base
  attr_reader :vacancy, :organisation

  steps do
    [
      {
        job_location: Publishers::JobListing::JobLocationForm,
        job_title: Publishers::JobListing::JobTitleForm,
        job_role: Publishers::JobListing::JobRoleForm,
        education_phases: Publishers::JobListing::EducationPhasesForm,
        key_stages: Publishers::JobListing::KeyStagesForm,
        subjects: Publishers::JobListing::SubjectsForm,
        contract_information: Publishers::JobListing::ContractInformationForm,
        pay_package: Publishers::JobListing::PayPackageForm,
        important_dates: Publishers::JobListing::ImportantDatesForm,
        start_date: Publishers::JobListing::StartDateForm,
        applying_for_the_job: Publishers::JobListing::ApplyingForTheJobForm,
        how_to_receive_applications: Publishers::JobListing::HowToReceiveApplicationsForm,
        application_link: Publishers::JobListing::ApplicationLinkForm,
        application_form: Publishers::JobListing::ApplicationFormForm,
        school_visits: Publishers::JobListing::SchoolVisitsForm,
        visa_sponsorship: Publishers::JobListing::VisaSponsorshipForm,
        contact_details: Publishers::JobListing::ContactDetailsForm,
        about_the_role: Publishers::JobListing::AboutTheRoleForm,
        include_additional_documents: Publishers::JobListing::IncludeAdditionalDocumentsForm,
        documents: Publishers::JobListing::DocumentsForm,
      },
    ]
  end

  def initialize(current_step, vacancy:, organisation:, step_params: {})
    @vacancy = vacancy
    @organisation = organisation

    super(current_step: current_step, step_params: step_params)
  end

  def step_missing?
    !current_step_name.in?(step_names)
  end

  def step_names
    step_groups.values.flatten
  end

  def step_groups
    {
      job_details: job_details_steps,
      important_dates: %i[important_dates start_date],
      application_process: application_process_steps,
      about_the_role: about_the_role_steps,
      review: %i[review],
    }
  end

  def current_step_group_number
    if current_step_name.in? job_details_steps
      1
    elsif current_step_name.in? important_date_steps
      2
    elsif current_step_name.in? application_process_steps
      3
    elsif current_step_name.in? about_the_role_steps
      4
    else
      5
    end
  end

  def total_step_groups
    5
  end

  # Returns the key of the previous step from the current one
  def previous_step
    return nil if current_step_name == step_names.first

    step_names[step_names.index(current_step_name) - 1]
  end

  def step_params
    param_key = "publishers_job_listing_#{current_step_name}_form"

    if @step_params && @step_params[param_key].present?
      @step_params.require(param_key).permit(*permitted_params)
                  .merge(vacancy: @vacancy).merge(completed_steps: completed_steps)
    end
  end

  def current_step_params
    super.merge(step_object_class.extra_params(@vacancy, step_params))
  end

  private

  def completed_steps
    (@vacancy.completed_steps | [current_step_name.to_s]).compact
  end

  def important_date_steps
    %i[important_dates start_date]
  end

  def job_details_steps
    steps = %i[job_location job_title job_role education_phases key_stages subjects contract_information pay_package]
    steps.delete(:job_location) if organisation.school?
    steps.delete(:education_phases) unless vacancy.allow_phase_to_be_set?
    steps.delete(:key_stages) unless vacancy.allow_key_stages?
    steps.delete(:subjects) unless vacancy.allow_subjects?

    steps
  end

  def application_process_steps
    if vacancy.published?
      steps = %i[school_visits visa_sponsorship contact_details]
      steps.insert(0, :how_to_receive_applications) unless vacancy.enable_job_applications
      steps.insert(1, application_method) if application_method.present?
    else
      steps = %i[applying_for_the_job school_visits visa_sponsorship contact_details]
      steps.insert(1, :how_to_receive_applications) unless vacancy.enable_job_applications
      steps.insert(2, application_method) if application_method.present?
    end

    steps
  end

  def about_the_role_steps
    steps = %i[about_the_role include_additional_documents documents]
    steps.delete(:documents) unless vacancy.include_additional_documents

    steps
  end

  def application_method
    return if vacancy.enable_job_applications

    case vacancy.receive_applications
    when "email"
      :application_form
    when "website"
      :application_link
    end
  end
end
