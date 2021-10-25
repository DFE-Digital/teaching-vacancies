class Publishers::VacancyStatisticsForm < BaseForm
  attr_accessor :hired_status, :listed_elsewhere

  validate :all_questions_completed

  def all_questions_completed
    return if hired_status.present? && listed_elsewhere.present?

    errors.add(:base, I18n.t("errors.publishers.job_statistics.base_error"))
  end
end
