class ImportantDatesForm < VacancyForm
  delegate :published?, :status, :publish_on_changed?, :expires_on_changed?, :starts_on_changed?,
           :publish_on, :expires_on, :expires_at, to: :vacancy

  attr_accessor :params, :expires_at_hh, :expires_at_mm, :expires_at_meridiem

  include DatesHelper

  include VacancyImportantDateValidations
  include VacancyExpiresAtFieldValidations

  def initialize(params)
    @params = params
    @expires_at_hh = params.delete(:expires_at_hh) || params[:expires_at]&.strftime("%-l")
    @expires_at_mm = params.delete(:expires_at_mm) || params[:expires_at]&.strftime("%-M")
    @expires_at_meridiem = params.delete(:expires_at_meridiem) || params[:expires_at]&.strftime("%P")

    super(params)
  end

  def disable_editing_publish_on?
    published? && vacancy.reload.publish_on.past?
  end

  def params_to_save
    params_with_expires_at = @params

    expires_at_attr = {
      day: expires_on&.day,
      month: expires_on&.month,
      year: expires_on&.year,
      hour: expires_at_hh,
      min: expires_at_mm,
      meridiem: expires_at_meridiem,
    }
    expires_at = compose_expires_at(expires_at_attr)
    params_with_expires_at[:expires_at] = expires_at unless expires_at.nil?

    params_with_expires_at
  end
end
