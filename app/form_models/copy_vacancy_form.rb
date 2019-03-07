class CopyVacancyForm < VacancyForm
  include ActiveModel::Model

  delegate :starts_on_yyyy, :starts_on_mm, :starts_on_dd,
           :ends_on_dd, :ends_on_mm, :ends_on_yyyy,
           :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
           :publish_on_dd, :publish_on_mm, :publish_on_yyyy,
           :errors, to: :vacancy

  validate :publish_on_must_not_be_in_the_past

  def publish_on_must_not_be_in_the_past
    return unless publish_on.past?

    errors.add(:publish_on, I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.before_today'))
  end

  def initialize(vacancy:)
    self.vacancy = vacancy
    self.job_title = vacancy.job_title

    self.publish_on = nil if vacancy.publish_on.past?
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
