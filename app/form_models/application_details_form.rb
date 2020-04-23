class ApplicationDetailsForm < VacancyForm
  delegate :published?, :status, :publish_on_changed?,
           :publish_on, :expires_on, :expiry_time, to: :vacancy

  attr_accessor :params, :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem

  include VacancyApplicationDetailValidations
  include VacancyExpiryTimeFieldValidations
  include DateHelper

  def initialize(params)
    @params = params
    @expiry_time_hh = params.delete(:expiry_time_hh) || params[:expiry_time]&.strftime('%-l')
    @expiry_time_mm = params.delete(:expiry_time_mm) || params[:expiry_time]&.strftime('%-M')
    @expiry_time_meridiem = params.delete(:expiry_time_meridiem) || params[:expiry_time]&.strftime('%P')

    super(params)
  end

  def disable_editing_publish_on?
    published? && vacancy.reload.publish_on.past?
  end

  def completed?
    application_link && contact_email && publish_on && expires_on && expiry_time
  end

  def attributes
    vacancy_attributes = @vacancy.attributes
    vacancy_attributes.merge!(
      expiry_time_hh: expiry_time_hh,
      expiry_time_mm: expiry_time_mm,
      expiry_time_meridiem: expiry_time_meridiem,
    )
    vacancy_attributes
  end

  def params_to_save
    params_with_expiry_time = @params

    expiry_time_attr = {
      day: expires_on&.day,
      month: expires_on&.month,
      year: expires_on&.year,
      hour: expiry_time_hh,
      min: expiry_time_mm,
      meridiem: expiry_time_meridiem
    }
    expiry_time = compose_expiry_time(expiry_time_attr)
    params_with_expiry_time[:expiry_time] = expiry_time unless expiry_time.nil?

    params_with_expiry_time
  end
end
