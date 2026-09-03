# frozen_string_literal: true

# This module is shared between vacancy decorator and vacancy template decorator
module ReadableVacancy
  def readable_job_role
    model.job_roles.map { |job_role|
      I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
    }.join(", ")
  end

  def readable_key_stages
    model.key_stages.map { |key_stage|
      I18n.t("helpers.label.publishers_job_listing_key_stages_form.key_stages_options.#{key_stage}")
    }.join(", ")
  end

  def readable_job_title
    model.job_title
  end

  def readable_working_patterns
    working_patterns = model.working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize

    return working_patterns unless model.is_job_share

    "#{working_patterns} (Can be done as a job share)"
  end

  def readable_working_patterns_details
    model.working_patterns_details
  end

  def readable_subjects
    model.subjects.join(", ")
  end

  # simplecov:disable
  def readable_contract_information # rubocop:disable Metrics/AbcSize
    return nil if model.contract_type.blank?

    return I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}") if model.fixed_term_contract_duration.blank?

    if model.is_parental_leave_cover
      [I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}"),  model.fixed_term_contract_duration, I18n.t("publishers.vacancies.build.contract_type.parental_leave")].join(" - ")
    else
      [I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}"),  model.fixed_term_contract_duration].join(" - ")
    end
  end
  # simplecov:enable
end
