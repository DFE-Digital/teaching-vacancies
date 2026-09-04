class VacancyDecorator < Draper::Decorator
  # TODO: try to reduce this surface by bringing methods into this class
  # to reduce logic in slim templates (which don't support coverage, and can get ungainly)
  delegate :school_group_names, :job_title, :organisation_name, :organisation, :organisations,
           :is_job_share, :id, :school_group_types,
           :publish_on, :skills_and_experience, :job_roles,
           :hourly_rate?, :hourly_rate, :salary?, :actual_salary?, :pay_scale?, :salary, :pay_scale, :actual_salary,
           :about_school, :expires_at, :expired?, :enable_job_applications?,
           :for_an_fe_college?, :live?, :uploaded_form?, :ect_suitable?,
           :slug, :allow_key_stages?, :allow_subjects?, :contract_type, :ect_status,
           :visa_sponsorship_available, :fixed_term_contract_duration, :school_offer, :flexi_working,
           :further_details, :include_additional_documents, :central_office?, :contact_email, :contact_number,
           :school_visits?, :location, :key_stages, :subjects, :benefits?, :supporting_documents,
           :application_link, :allow_phase_to_be_set?, :published?, :draft?, :pending?,
           :salary_types, :benefits,
           :working_patterns_details?, :working_patterns_details,
           :completed_steps, :phases, :further_details_provided, :school_visits, :contact_number_provided, :contact_number_provided?,
           :receive_applications, :allow_job_applications?, :can_receive_job_applications?, :enable_job_applications,
           :catholic?, :religious_character, :other_religion?, :anonymise_applications?, :is_parental_leave_cover, :email?,
           :application_form, :application_email, :website?, :vacancy_address,
           :external?, :job_advert, :external_advert_url,
           :supporting_documents_in_order,
           :other_start_date_details, :earliest_start_date, :latest_start_date, :starts_on, :start_date_type,
           :teaching_or_middle_leader_role?

  include ActionView::Helpers::TextHelper

  include ReadableVacancy

  HTML_STRIP_REGEX = %r{(&nbsp;|<div>|</div>|<!--block-->)+}

  # simplecov:disable
  def benefits_details
    simple_format(fix_bullet_points(model.benefits_details)) if model.benefits_details.present?
  end
  # simplecov:enable

  # simplecov:disable
  def working_patterns_for_job_schema
    [
      ("FULL_TIME" if model.working_patterns.include? "full_time"),
      ("PART_TIME" if model.working_patterns.include? "part_time"),
      ("TEMPORARY" if model.fixed_term_contract_duration?),
      ("OTHER" if model.working_patterns.any?("job_share") && !model.fixed_term_contract_duration?),
    ].compact
  end
  # simplecov:enable

  # simplecov:disable
  def readable_ect_status
    return if model.ect_status.blank?

    I18n.t("helpers.label.publishers_job_listing_about_the_role_form.ect_status_options.#{model.ect_status}")
  end
  # simplecov:enable

  def section_begun?(section, step_process)
    retrieve_section_forms(section, step_process)
      .map { |form_class| form_class.load_from_model(model, current_publisher: nil).slice(*form_class.fields).values }
      .flatten
      .any? { |value| !value.nil? }
  end

  def working_patterns_any?
    model.working_patterns.any?
  end

  def readable_working_patterns
    working_patterns = model.working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize

    return working_patterns unless model.is_job_share

    "#{working_patterns} (Can be done as a job share)"
  end

  def readable_working_patterns_with_details
    if model.working_patterns_details.present?
      "#{readable_working_patterns}: #{model.working_patterns_details}"
    else
      readable_working_patterns
    end
  end

  def fe_role_qts_required
    I18n.t("helpers.label.publishers_job_listing_about_the_role_form.fe_role_qts_required_options.#{model.fe_role_qts_required}")
  end

  private

  def retrieve_section_forms(section, step_process)
    step_process.step_groups[section].map do |step_name|
      File.join("publishers/job_listing", "#{step_name}_form").camelize.constantize
    end
  end

  # simplecov:disable
  def fix_bullet_points(text) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
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
  # simplecov:enable

  # simplecov:disable
  def normalize_bullets(text, normalized_bullet)
    return unless text

    # `⁃` is a hyphen bullet, not an en-dash or a hyphen.
    text.gsub("⁃", normalized_bullet).gsub("·", normalized_bullet).gsub("∙", normalized_bullet)
  end
  # simplecov:enable

  # simplecov:disable
  def normalize_newlines(text)
    # Required for backwards-compatibility for fields created with a rich-text editor
    text&.gsub("<br>", "\n")
  end
  # simplecov:enable

  def strip(text)
    text.gsub(/\s+/, "").gsub(HTML_STRIP_REGEX, "")
  end
end
