class ExternalVacancyValidator < ActiveModel::Validator
  def validate(record)
    validate_presence(
      record,
      :job_title, :job_advert, :salary, :expires_at,
      :external_reference, :external_advert_url,
      :job_roles, :contract_type, :phases, :working_patterns
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
