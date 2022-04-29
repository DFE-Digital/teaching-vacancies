class ExternalVacancyValidator < ActiveModel::Validator
  def validate(record)
    validate_presence(
      record,
      :job_title, :job_advert, :salary, :publish_on, :expires_at,
      :external_reference, :external_advert_url
    )

    record.errors.add(:organisations, "No school(s) associated with vacancy") if record.organisations.empty?
  end

  private

  def validate_presence(record, *fields)
    ActiveModel::Validations::PresenceValidator
      .new(attributes: fields)
      .validate(record)
  end
end
