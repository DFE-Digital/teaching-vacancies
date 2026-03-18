# frozen_string_literal: true

module ReadableVacancyHelper
  def vacancy_readable_working_patterns(model)
    working_patterns = model.working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize

    return working_patterns unless model.is_job_share

    "#{working_patterns} (Can be done as a job share)"
  end

  def vacancy_readable_working_patterns_with_details(model)
    if model.working_patterns_details.present?
      "#{vacancy_readable_working_patterns(model)}: #{model.working_patterns_details}"
    else
      vacancy_readable_working_patterns(model)
    end
  end

  # :nocov:
  def vacancy_contract_type_with_duration(model)
    return nil if model.contract_type.blank?

    return I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}") if model.fixed_term_contract_duration.blank?

    if model.is_parental_leave_cover
      [I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}"),  model.fixed_term_contract_duration, I18n.t("publishers.vacancies.build.contract_type.parental_leave")].compact.join(" - ")
    else
      [I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}"),  model.fixed_term_contract_duration].compact.join(" - ")
    end
  end
  # :nocov:

  # :nocov:
  def vacancy_readable_job_roles(model)
    model.job_roles&.map { |job_role|
      I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
    }&.join(", ")
  end
  # :nocov:

  # :nocov:
  def vacancy_readable_key_stages(model)
    model.key_stages&.map { |key_stage|
      I18n.t("helpers.label.publishers_job_listing_key_stages_form.key_stages_options.#{key_stage}")
    }&.join(", ")
  end
  # :nocov:

  def vacancy_readable_subjects(model)
    model.subjects.join(", ")
  end

  def vacancy_readable_visa_sponsorship_availability(model)
    ["visa sponsorship"] if model.visa_sponsorship_available
  end

  def school_group_names
    organisations.map { |organisation|
      if organisation.is_a?(SchoolGroup)
        organisation.name
      else
        organisation.school_groups.map(&:name).compact_blank
      end
    }.flatten.uniq
  end

  def school_group_types
    organisations.map { |organisation|
      if organisation.is_a?(SchoolGroup)
        organisation.group_type
      else
        organisation.school_groups.map(&:group_type).compact_blank
      end
    }.flatten.uniq
  end

  def religious_character
    organisations.filter_map { |organisation| organisation.religious_character if organisation.is_a?(School) }
  end
end
