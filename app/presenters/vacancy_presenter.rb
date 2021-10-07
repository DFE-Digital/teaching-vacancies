class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  delegate :location, to: :organisation
  delegate :working_patterns, to: :model, prefix: true
  delegate :job_roles, to: :model, prefix: true

  HTML_STRIP_REGEX = %r{(&nbsp;|<div>|</div>|<!--block-->)+}

  def share_url(utm_source: nil, utm_medium: nil, utm_campaign: nil, utm_content: nil)
    params = {}
    if utm_source.present?
      params.merge!(
        utm_source: utm_source,
        utm_medium: utm_medium,
        utm_campaign: utm_campaign,
        utm_content: utm_content,
      )
    end
    Rails.application.routes.url_helpers.job_url(model, params)
  end

  def job_advert
    simple_format(fix_bullet_points(model.job_advert))
  end

  def about_school
    simple_format(fix_bullet_points(model.about_school))
  end

  def school_visits
    simple_format(fix_bullet_points(model.school_visits)) if model.school_visits.present?
  end

  def how_to_apply
    simple_format(model.how_to_apply) if model.how_to_apply.present?
  end

  def benefits
    simple_format(fix_bullet_points(model.benefits)) if model.benefits.present?
  end

  def expired?
    model.expires_at < Time.current
  end

  def publish_today?
    model.publish_on == Date.current
  end

  def working_patterns?
    model_working_patterns.present?
  end

  def working_patterns
    return unless working_patterns?

    patterns = model_working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ")

    I18n.t("jobs.working_patterns_info", patterns: patterns, count: model_working_patterns.count).capitalize
  end

  def show_working_patterns
    if model.working_patterns_details?
      safe_join([working_patterns, tag.br, tag.span(model.working_patterns_details, class: "govuk-hint govuk-!-margin-bottom-0")])
    else
      working_patterns
    end
  end

  def working_patterns_for_job_schema
    model_working_patterns.compact.map(&:upcase).join(", ")
  end

  def all_job_roles
    # TODO: This line can go at some point after the 30th of September 2021 (when all the legacy vacancies have expired)
    #       and once people no longer need to view the legacy vacancies for reference.
    return show_job_roles unless main_job_role

    safe_join [show_main_job_role, tag.br, model.additional_job_roles.map { |role| greyed_additional_job_role(role) }]
  end

  def show_main_job_role
    I18n.t("helpers.label.publishers_job_listing_job_role_form.main_job_role_options.#{main_job_role}")
  end

  def show_additional_job_roles
    return unless model.additional_job_roles.any?

    tag.ul safe_join(model.additional_job_roles.map { |role| tag.li additional_job_role(role) }), class: "govuk-list"
  end

  def additional_job_role(role)
    I18n.t("helpers.label.publishers_job_listing_job_role_details_form.additional_job_roles_options.#{role}")
  end

  def show_job_roles(exclude_ect_suitable: false)
    roles = exclude_ect_suitable ? model.job_roles.excluding("ect_suitable") : model.job_roles
    roles.map { |role| I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.#{role}") }.join(", ")
  end

  def show_key_stages
    model.key_stages&.map { |key_stage|
      I18n.t("helpers.label.publishers_job_listing_job_details_form.key_stages_options.#{key_stage}")
    }&.join(", ")
  end

  def show_subjects
    model.subjects&.join(", ")
  end

  def contract_type_with_duration
    type = model.contract_type ? I18n.t("helpers.label.publishers_job_listing_job_details_form.contract_type_options.#{model.contract_type}") : nil
    duration = model.fixed_term? ? "(#{model.contract_type_duration})" : nil
    [type, duration].compact.join(" ")
  end

  private

  def greyed_additional_job_role(role)
    tag.span additional_job_role(role), class: "govuk-hint govuk-!-margin-bottom-0"
  end

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
