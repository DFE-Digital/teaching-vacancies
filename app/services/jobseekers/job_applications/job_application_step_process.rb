class Jobseekers::JobApplications::JobApplicationStepProcess < StepProcess
  attr_reader :job_application

  PRE_RELIGION_STEPS = { personal_details: %i[personal_details],
                         professional_status: %i[professional_status],
                         qualifications: %i[qualifications],
                         training_and_cpds: %i[training_and_cpds],
                         employment_history: %i[employment_history],
                         personal_statement: %i[personal_statement] }.freeze

  POST_RELIGION_STEPS = {
    references: %i[references],
    equal_opportunities: %i[equal_opportunities],
    ask_for_support: %i[ask_for_support],
    declarations: %i[declarations],
    review: %i[review],
  }.freeze

  ALL_CATHOLIC_STEPS = %i[catholic_following_religion catholic_religion_details].freeze

  ALL_NON_CATHOLIC_STEPS = %i[school_ethos non_catholic_following_religion non_catholic_religion_details].freeze

  def initialize(current_step, job_application:)
    @job_application = job_application

    religious_steps = case job_application.vacancy.religion_type
                      when "catholic"
                        catholic_steps job_application
                      when "other_religion"
                        other_religion_steps job_application
                      else
                        []
                      end

    step_groups = if religious_steps.any?
                    PRE_RELIGION_STEPS.merge(religious_information: religious_steps).merge(POST_RELIGION_STEPS)
                  else
                    PRE_RELIGION_STEPS.merge(POST_RELIGION_STEPS)
                  end

    super(current_step, step_groups)
  end

  def all_possible_steps
    steps = case job_application.vacancy.religion_type
            when "catholic"
              PRE_RELIGION_STEPS.merge(religious_information: ALL_CATHOLIC_STEPS).merge(POST_RELIGION_STEPS)
            when "other_religion"
              PRE_RELIGION_STEPS.merge(religious_information: ALL_NON_CATHOLIC_STEPS).merge(POST_RELIGION_STEPS)
            else
              PRE_RELIGION_STEPS.merge(POST_RELIGION_STEPS)
            end
    steps.values.flatten
  end

  private

  def catholic_steps(job_application)
    if job_application.following_religion || job_application.following_religion.nil?
      ALL_CATHOLIC_STEPS
    else
      ALL_CATHOLIC_STEPS - [:catholic_religion_details]
    end
  end

  def other_religion_steps(job_application)
    if job_application.following_religion || job_application.following_religion.nil?
      ALL_NON_CATHOLIC_STEPS
    else
      ALL_NON_CATHOLIC_STEPS - [:non_catholic_religion_details]
    end
  end
end
