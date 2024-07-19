class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper

  HTML_STRIP_REGEX = %r{(&nbsp;|<div>|</div>|<!--block-->)+}

  def columns
    model.class.columns
  end

  def about_school
    simple_format(fix_bullet_points(model.about_school)) if model.about_school.present?
  end

  def how_to_apply
    simple_format(fix_bullet_points(model.how_to_apply)) if model.how_to_apply.present?
  end

  def benefits_details
    simple_format(fix_bullet_points(model.benefits_details)) if model.benefits_details.present?
  end

  def job_advert
    return if model.job_advert.blank?

    # Basic HTML formatting of text if it is not already HTML
    model.job_advert.strip.starts_with?("<") ? model.job_advert : simple_format(model.job_advert)
  end

  def readable_working_patterns
    working_patterns = model.working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize

    return working_patterns unless is_job_share

    "#{working_patterns} (Can be done as a job share)"
  end

  def readable_working_patterns_with_details
    if model.working_patterns_details.present?
      "#{readable_working_patterns}: #{model.working_patterns_details}"
    else
      readable_working_patterns
    end
  end

  def working_patterns_for_job_schema
    [
      ("FULL_TIME" if model.working_patterns.include? "full_time"),
      ("PART_TIME" if model.working_patterns.include? "part_time"),
      ("TEMPORARY" if model.fixed_term_contract_duration?),
      ("OTHER" if model.working_patterns.any? { |working_pattern| working_pattern.in? %w[flexible job_share term_time] } && !model.fixed_term_contract_duration?),
    ].compact
  end

  def readable_visa_sponsorship_availability
    ["visa sponsorship"] if model.visa_sponsorship_available
  end

  def readable_job_roles
    model.job_roles&.map { |job_role|
      I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
    }&.join(", ")
  end

  def readable_ect_status
    return unless model.ect_status.present?

    I18n.t("helpers.label.publishers_job_listing_about_the_role_form.ect_status_options.#{model.ect_status}")
  end

  def readable_key_stages
    model.key_stages&.map { |key_stage|
      I18n.t("helpers.label.publishers_job_listing_key_stages_form.key_stages_options.#{key_stage}")
    }&.join(", ")
  end

  def readable_subjects
    model.subjects&.join(", ")
  end

  def contract_type_with_duration
    return nil unless model.contract_type.present?

    return I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}") if model.fixed_term_contract_duration.blank?

    if is_parental_leave_cover
      [I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}"),  model.fixed_term_contract_duration, I18n.t("publishers.vacancies.build.contract_type.parental_leave")].compact.join(" - ")
    else
      [I18n.t("publishers.vacancies.build.contract_type.#{model.contract_type}"),  model.fixed_term_contract_duration].compact.join(" - ")
    end
  end

  def school_group_names
    organisations.map { |organisation|
      if organisation.is_a?(SchoolGroup)
        organisation.name
      else
        organisation.school_groups.map(&:name).reject(&:blank?)
      end
    }.flatten.uniq
  end

  def school_group_types
    organisations.map { |organisation|
      if organisation.is_a?(SchoolGroup)
        organisation.group_type
      else
        organisation.school_groups.map(&:group_type).reject(&:blank?)
      end
    }.flatten.uniq
  end

  def religious_character
    organisations.filter_map { |organisation| organisation.religious_character if organisation.is_a?(School) }
  end

  private

  def fix_bullet_points(text)
    # This is a band-aid solution for the problem where (particularly) job adverts contain bullet point characters
    # (not list elements), but do not contain corresponding newlines, resulting in inline bullets.
    bullet = "•"
    text = normalize_newlines(text)
    text = normalize_bullets(text, bullet)
    return text unless text&.count(bullet)&.positive?

    text.split("\n").map { |para|
      next para if para.count(bullet) <= 1 # If paragraph only has one bullet point it is probably correctly formatted

      first_bulleted_line_idx = strip(para).first == bullet ? 0 : 1
      para.split(bullet).reject { |line| strip(line).blank? }.map.with_index { |line, index|
        item = "<li>#{line.gsub(HTML_STRIP_REGEX, '')}</li>"
        index == first_bulleted_line_idx ? "<ul>#{item}" : item
      }.join.concat("</ul>")
    }.join("\n")
  end

  def normalize_bullets(text, normalized_bullet)
    # `⁃` is a hyphen bullet, not an en-dash or a hyphen.
    text&.gsub("⁃", normalized_bullet)&.gsub("·", normalized_bullet)&.gsub("∙", normalized_bullet)
  end

  def normalize_newlines(text)
    # Required for backwards-compatibility for fields created with a rich-text editor
    text&.gsub("<br>", "\n")
  end

  def strip(text)
    text.gsub(/\s+/, "").gsub(HTML_STRIP_REGEX, "")
  end
end
