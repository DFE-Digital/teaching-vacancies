class Jobseekers::JobApplications::JobApplicationStepProcess
  attr_reader :job_application

  PRE_RELIGION_STEPS = { personal_details: %i[personal_details],
                         professional_status: %i[professional_status],
                         qualifications: %i[qualifications],
                         training_and_cpds: %i[training_and_cpds],
                         professional_body_memberships: %i[professional_body_memberships],
                         employment_history: %i[employment_history],
                         personal_statement: %i[personal_statement] }.freeze

  POST_RELIGION_STEPS = {
    referees: %i[referees],
    equal_opportunities: %i[equal_opportunities],
    ask_for_support: %i[ask_for_support],
    declarations: %i[declarations],
  }.freeze

  def initialize(job_application:)
    @job_application = job_application

    religious_steps = if job_application.vacancy.catholic?
                        { catholic: [:catholic] }
                      elsif job_application.vacancy.other_religion?
                        { non_catholic: [:non_catholic] }
                      else
                        {}
                      end

    @step_groups = PRE_RELIGION_STEPS.merge(religious_steps).merge(POST_RELIGION_STEPS)
  end

  # Returns the keys of all individual steps in order
  def steps
    @step_groups.values.flatten
  end

  def validatable_steps
    steps.excluding(:review).map(&:to_s)
  end

  def next_step(step)
    steps[steps.index(step) + 1]
  end

  def last_of_group?(step)
    group = @step_groups.values.detect { |g| g.include?(step) }
    step == group.last
  end

  def form_class_for(step)
    "jobseekers/job_application/#{step}_form".camelize.constantize
  end
end
