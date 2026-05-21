class SavedJobDecorator < Draper::Decorator
  delegate_all
  delegate :vacancy, :created_at, :id, to: :object

  def initialize(saved_job, jobseeker)
    super(saved_job)
    @jobseeker = jobseeker
  end

  def submitted_application
    return @submitted_application if defined?(@submitted_application)

    @submitted_application = @jobseeker.job_applications.after_submission.find_by(vacancy_id: vacancy.id)
  end

  def draft_application
    return @draft_application if defined?(@draft_application)

    @draft_application = @jobseeker.job_applications.draft.find_by(vacancy_id: vacancy.id)
  end

  def job_application
    submitted_application || draft_application
  end

  def action
    return unless vacancy.accepting_applications?

    if submitted_application.present?
      :view
    elsif draft_application.present?
      :continue
    else
      :apply
    end
  end
end
