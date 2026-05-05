class Jobseekers::JobApplications::JobApplicationStepProcess
  PRE_RELIGION_STEPS = %i[personal_details professional_status qualifications training_and_cpds professional_body_memberships employment_history personal_statement].freeze

  POST_RELIGION_STEPS = %i[referees equal_opportunities ask_for_support declarations].freeze

  attr_reader :job_application, :steps

  def initialize(job_application:)
    @job_application = job_application

    religious_steps = if job_application.vacancy.catholic?
                        [:catholic]
                      elsif job_application.vacancy.other_religion?
                        [:non_catholic]
                      else
                        []
                      end

    @steps = PRE_RELIGION_STEPS + religious_steps + POST_RELIGION_STEPS
  end

  def validatable_steps
    steps.map(&:to_s)
  end

  def form_class_for(step)
    "jobseekers/job_application/#{step}_form".camelize.constantize
  end
end
