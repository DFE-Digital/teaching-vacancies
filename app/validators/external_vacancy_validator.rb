class ExternalVacancyValidator < ActiveModel::Validator
  def validate(record)
    validate_presence(
      record,
      :job_title, :job_advert, :salary, :expires_at,
      :external_reference, :external_advert_url,
      :job_roles, :contract_type, :phases, :working_patterns
    )

    record.errors.add(:organisations, "No school(s) associated with vacancy") if record.organisations.empty?
    validate_uniqueness_per_client(record)
    validate_no_duplicate_vacancy(record)
    validate_job_title_length(record)
    validate_expiry_date(record) if record.expires_at.present?
  end

  private

  def validate_uniqueness_per_client(record)
    if record.find_external_reference_conflict_vacancy.present?
      record.errors.add(
        :external_reference,
        I18n.t("activerecord.errors.models.vacancy.attributes.external_reference.taken"),
      )
    end
  end

  def validate_no_duplicate_vacancy(record)
    if record.find_duplicate_external_vacancy.present?
      record.errors.add(:base, "A vacancy with the same job title, expiry date, contract type, working patterns, phases and salary already exists for this organisation.")
    end
  end

  def validate_presence(record, *fields)
    ActiveModel::Validations::PresenceValidator
      .new(attributes: fields)
      .validate(record)
  end

  def validate_job_title_length(record)
    ActiveModel::Validations::LengthValidator
      .new(attributes: [:job_title], maximum: 75, too_long: "must be 75 characters or fewer")
      .validate(record)
  end

  def validate_expiry_date(record)
    if record.expires_at <= Time.zone.today
      record.errors.add(:expires_at, "must be a future date")
    end

    if record.publish_on && record.expires_at <= record.publish_on
      record.errors.add(:expires_at, "must be later than the publish date")
    end
  end
end
