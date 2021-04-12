class Jobseekers::JobApplication::ReviewForm
  include ActiveModel::Model

  attr_accessor :confirm_data_accurate, :confirm_data_usage, :completed_steps

  validates :confirm_data_accurate, acceptance: true
  validates :confirm_data_usage, acceptance: true
  validate :all_steps_completed

  def all_steps_completed
    JobApplication.completed_steps.each_key do |step|
      next if step.in?(completed_steps)

      errors.add(
        step.to_sym,
        I18n.t("activemodel.errors.models.jobseekers/job_application/review_form.attributes.#{step}.incomplete"),
      )
    end
  end
end
