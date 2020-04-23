class CopyVacancyForm < VacancyForm
  include ActiveModel::Model
  include DateHelper

  include VacancyCopyValidations
  include VacancyImportantDateValidations
  include VacancyExpiryTimeFieldValidations

  delegate :starts_on, :ends_on, :publish_on, :expires_on, :errors, to: :vacancy

  attr_accessor :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem

  def initialize(vacancy:)
    @expiry_time_hh = vacancy.expiry_time&.strftime('%-l')
    @expiry_time_mm = vacancy.expiry_time&.strftime('%-M')
    @expiry_time_meridiem = vacancy.expiry_time&.strftime('%P')

    self.vacancy = vacancy
    self.vacancy.status = 'draft'

    self.job_title = vacancy.job_title
    self.job_roles = vacancy.job_roles
    self.about_school = vacancy.about_school
    self.publish_on = nil if vacancy.publish_on.past?

    reset_date_fields if vacancy.expires_on.past?
  end

  def apply_changes!(params = {})
    assign_attributes(params.extract!(:expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem))
    vacancy.assign_attributes(params)
    vacancy
  end

  def update_expiry_time(vacancy, params)
    expiry_time_attr = {
      day: vacancy.expires_on&.day,
      month: vacancy.expires_on&.month,
      year: vacancy.expires_on&.year,
      hour: params[:expiry_time_hh],
      min: params[:expiry_time_mm],
      meridiem: params[:expiry_time_meridiem]
    }
    expiry_time = compose_expiry_time(expiry_time_attr)
    vacancy.expiry_time = expiry_time unless expiry_time.nil?
  end

  private

  def reset_date_fields
    self.starts_on  = nil
    self.ends_on    = nil
    self.expires_on = nil
    self.publish_on = nil
  end
end
