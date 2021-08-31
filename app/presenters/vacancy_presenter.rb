class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  delegate :location, to: :organisation
  delegate :working_patterns, to: :model, prefix: true
  delegate :job_roles, to: :model, prefix: true

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
    simple_format(model.benefits) if model.benefits.present?
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

    I18n.t("jobs.working_patterns_info_#{model_working_patterns.count > 1 ? 'many' : 'one'}", patterns: patterns)
        .capitalize
  end

  def working_patterns_for_job_schema
    model_working_patterns.compact.map(&:upcase).join(", ")
  end

  def show_job_roles(exclude_nqt_suitable: false)
    roles = exclude_nqt_suitable ? model.job_roles.excluding("nqt_suitable") : model.job_roles
    roles.map { |role| I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.#{role}") }.join(", ")
  end

  def show_primary_job_role
    I18n.t("helpers.label.publishers_job_listing_job_role_form.primary_job_role_options.#{primary_job_role}")
  end

  def show_additional_job_roles
    tag.ul safe_join(model.additional_job_roles.map { |role| tag.li additional_job_role(role) }), class: "govuk-list"
  end

  def additional_job_role(role)
    I18n.t("helpers.label.publishers_job_listing_job_role_details_form.additional_job_roles_options.#{role}")
  end

  def public_job_roles
    safe_join [show_primary_job_role, tag.br, model.additional_job_roles.map { |role| greyed_additional_job_role(role) }]
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

  # rubocop:disable Style/AsciiComments
  def fix_bullet_points(text)
    # This is a band-aid solution for the problem where (particularly) job adverts contain `•` but
    # do not contain corresponding newlines, resulting in inline bullets.
    bullet = "•"
    text = normalize_bullets(text, bullet)
    return text unless text&.count(bullet)&.positive?

    paragraphs = text.split("\n") # Presume newline signals end of unordered list
    paragraphs.map { |para|
      if para.count(bullet).zero?
        para
      else
        first_bulleted_line_idx = para.gsub(/\s+/, "").first == bullet ? 0 : 1
        para.split(bullet).reject(&:blank?).map.with_index { |line, index|
          item = "<li>#{line}</li>"
          index == first_bulleted_line_idx ? "<ul>#{item}" : item
        }.join.concat("</ul>")
      end
    }.join("\n")
  end

  def normalize_bullets(text, normalized_bullet)
    # `⁃` is a hyphen bullet, not an en-dash or a hyphen.
    text&.gsub("⁃", normalized_bullet)&.gsub("·", normalized_bullet)&.gsub("∙", normalized_bullet)
  end
  # rubocop:enable Style/AsciiComments
end
