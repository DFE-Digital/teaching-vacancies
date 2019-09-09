class ApplicationDetailsForm < VacancyForm
  validate :validate_expiry_time

  delegate :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
           :publish_on_dd, :publish_on_mm, :publish_on_yyyy,
           :published?, :status, :publish_on_changed?, :expiry_time, to: :vacancy

  attr_accessor :params, :expiry_time_hh, :expiry_time_mm, :expiry_time_meridian

  include VacancyApplicationDetailValidations

  def initialize(params)
    @params = params
    @expiry_time_hh = params.delete(:expiry_time_hh) || params[:expiry_time]&.strftime('%-l')
    @expiry_time_mm = params.delete(:expiry_time_mm) || params[:expiry_time]&.strftime('%-M')
    @expiry_time_meridian = params.delete(:expiry_time_meridian) || params[:expiry_time]&.strftime('%P')

    super(params)
  end

  def disable_editing_publish_on?
    published? && vacancy.reload.publish_on.past?
  end

  def completed?
    application_link && contact_email && publish_on && expires_on && expiry_time
  end

  def validate_expiry_time
    return create_blank_error if expiry_time_hh.blank? || expiry_time_mm.blank?
    return create_wrong_format_error unless in_range?(expiry_time_hh, 1, 12)
    return create_wrong_format_error unless in_range?(expiry_time_mm, 0, 59)
    return create_meridian_error if expiry_time_meridian.blank?
  end

  def attributes
    vacancy_attributes = @vacancy.attributes
    vacancy_attributes.merge!(
      expiry_time_hh: expiry_time_hh,
      expiry_time_mm: expiry_time_mm,
      expiry_time_meridian: expiry_time_meridian,
    )
    vacancy_attributes
  end

  def params_to_save
    params_with_expiry_time = @params
    params_with_expiry_time[:expiry_time] = compose_expiry_time if compose_expiry_time

    params_with_expiry_time
  end

  def compose_expiry_time
    return nil if [expiry_time_hh, expiry_time_mm, expiry_time_meridian].any? { |attr| attr.to_s.empty? }

    expiry_time_string = "#{expires_on_dd}-#{expires_on_mm}-#{expires_on_yyyy}" \
                         " #{expiry_time_hh}:#{expiry_time_mm} #{expiry_time_meridian}"

    Time.zone.parse(expiry_time_string)
  end

  def in_range?(value, min, max)
    number?(value) && value.to_i >= min && value.to_i <= max
  end

  def number?(value)
    /\A[+-]?\d+\z/.match?(value)
  end

  def create_wrong_format_error
    errors.add(:expiry_time, I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.wrong_format'))
  end

  def create_blank_error
    errors.add(:expiry_time, I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.blank'))
  end

  def create_meridian_error
    errors.add(:expiry_time, I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.must_be_am_pm'))
  end
end
