class Jobseekers::JobApplications::JobApplicationStepProcess < StepProcess
  attr_reader :job_application

  def initialize(current_step, job_application:)
    @job_application = job_application

    super(current_step, {
      personal_details: %i[personal_details],
      professional_status: %i[professional_status],
      qualifications: %i[qualifications],
      training_and_cpds: %i[training_and_cpds],
      employment_history: %i[employment_history],
      personal_statement: %i[personal_statement],
      references: %i[references],
      equal_opportunities: %i[equal_opportunities],
      ask_for_support: %i[ask_for_support],
      declarations: %i[declarations],
      review: %i[review],
    })
  end
end
