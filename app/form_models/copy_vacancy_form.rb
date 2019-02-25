class CopyVacancyForm < VacancyForm
  include ActiveModel::Model

  delegate :starts_on_yyyy, :starts_on_mm, :starts_on_dd,
           :ends_on_dd, :ends_on_mm, :ends_on_yyyy,
           :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
           :publish_on_dd, :publish_on_mm, :publish_on_yyyy,
           :errors, to: :vacancy

  def initialize(vacancy:)
    self.vacancy = vacancy
    self.job_title = vacancy.job_title
    reset_date_fields if vacancy.expires_on.past?
  end

  def apply_changes!(params = {})
    vacancy.assign_attributes(params)
    vacancy
  end

  private

  def reset_date_fields
    self.starts_on  = nil
    self.ends_on    = nil
    self.expires_on = nil
    self.publish_on = nil
  end
end
