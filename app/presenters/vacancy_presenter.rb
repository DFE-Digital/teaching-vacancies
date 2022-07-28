class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper

  HTML_STRIP_REGEX = %r{(&nbsp;|<div>|</div>|<!--block-->)+}

  def columns
    model.class.columns
  end

  def about_school
    simple_format(fix_bullet_points(model.about_school))
  end

  def school_visits
    simple_format(fix_bullet_points(model.school_visits)) if model.school_visits.present?
  end

  def how_to_apply
    simple_format(fix_bullet_points(model.how_to_apply)) if model.how_to_apply.present?
  end

  def benefits
    simple_format(fix_bullet_points(model.benefits)) if model.benefits.present?
  end

  def readable_working_patterns
    model.working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize
  end

  def working_patterns_for_job_schema
    [
      ("FULL_TIME" if model.working_patterns.include? "full_time"),
      ("PART_TIME" if model.working_patterns.include? "part_time"),
      ("TEMPORARY" if model.fixed_term_contract_duration?),
      ("OTHER" if model.working_patterns.any? { |working_pattern| working_pattern.in? %w[flexible job_share term_time] } && !model.fixed_term_contract_duration?),
    ].compact
  end

  def readable_job_role
    I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}") if job_role
  end

  def readable_ect_status
    return unless model.ect_status.present?

    I18n.t("helpers.label.publishers_job_listing_job_role_details_form.ect_status_options.#{model.ect_status}")
  end

  def readable_key_stages
    model.key_stages&.map { |key_stage|
      I18n.t("helpers.label.publishers_job_listing_job_details_form.key_stages_options.#{key_stage}")
    }&.join(", ")
  end

  def readable_subjects
    model.subjects&.join(", ")
  end

  def contract_type_with_duration
    type = model.contract_type ? I18n.t("helpers.label.publishers_job_listing_job_details_form.contract_type_options.#{model.contract_type}") : nil
    duration = if model.fixed_term?
                 "(#{model.fixed_term_contract_duration})"
               elsif model.parental_leave_cover?
                 "(#{model.parental_leave_cover_contract_duration})"
               end
    [type, duration].compact.join(" ")
  end

  def school_group_names
    return organisations.map(&:name) if organisations.none?(&:school?)

    organisations.map(&:school_groups).flatten.map(&:name).uniq
  end

  def school_group_types
    return organisations.map(&:group_type) if organisations.none?(&:school?)

    organisations.map(&:school_groups).flatten.map(&:group_type).reject(&:blank?).uniq
  end

  def religious_character
    organisations.map(&:religious_character).reject(&:blank?).uniq unless organisations.none?(&:school?)
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
