module HiringStaff::JobCreationHelper
  NUMBER_OF_ADDITIONAL_STEPS_FOR_SCHOOL_GROUP_USERS = 1

  STEPS = {
    job_location: { number: 1, title: I18n.t("jobs.job_location") },
    schools: { number: 1, title: I18n.t("jobs.job_location") },
    job_details: { number: 2, title: I18n.t("jobs.job_details") },
    pay_package: { number: 3, title: I18n.t("jobs.pay_package") },
    important_dates: { number: 4, title: I18n.t("jobs.important_dates") },
    supporting_documents: { number: 5, title: I18n.t("jobs.supporting_documents") },
    documents: { number: 5, title: I18n.t("jobs.supporting_documents") },
    applying_for_the_job: { number: 6, title: I18n.t("jobs.applying_for_the_job") },
    job_summary: { number: 7, title: I18n.t("jobs.job_summary") },
    review: { number: 8, title: I18n.t("jobs.review_heading") },
  }.freeze

  def current_step_number
    current_step = if defined?(step)
                     step
                   else
                     params[:controller].split("/").last.to_sym == :documents ? :documents : :review
                   end
    if school_group_user?
      STEPS[current_step][:number]
    else
      STEPS[current_step][:number] - NUMBER_OF_ADDITIONAL_STEPS_FOR_SCHOOL_GROUP_USERS
    end
  end

  def steps_to_display
    steps = STEPS.dup
    unless school_group_user?
      steps = remove_school_group_user_only_steps(steps)
      steps = renumber_steps_for_single_school_users(steps)
    end
    steps
  end

  def remove_school_group_user_only_steps(steps)
    # Step 1a and 1b: Job location and school selection
    steps.delete_if { |_k, v| v[:number] == 1 }
  end

  def renumber_steps_for_single_school_users(steps)
    steps.transform_values do |v|
      { number: v[:number] - NUMBER_OF_ADDITIONAL_STEPS_FOR_SCHOOL_GROUP_USERS, title: v[:title] }
    end
  end

  def total_steps
    steps_to_display.values.map { |h| h[:number] }.max
  end

  def set_active_step_class(step_number)
    return "app-step-nav__step--active" if current_step_number == step_number
  end

  def set_visited_step_class(step_number, vacancy)
    completed_step = vacancy.completed_step.presence || 0
    return "app-step-nav__step--visited" if
      step_number != current_step_number && step_number <= completed_step
  end
end
