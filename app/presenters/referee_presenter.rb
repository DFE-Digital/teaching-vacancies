class RefereePresenter < BasePresenter
  REFEREE_DETAILS = %i[name job_title organisation relationship email phone_number].freeze
  REF_INFO = %i[how_do_you_know_the_candidate employment_start_date currently_employed would_reemploy_current would_reemploy_any].freeze

  def initialize(referee)
    super
    @referee = referee
    @reference = referee.job_reference
  end

  attr_reader :referee, :reference

  delegate :can_give_reference?, to: :reference

  def referee_details
    Enumerator.new do |y|
      REFEREE_DETAILS.each { y << referee_details_row(it) }
    end
  end

  def reference_information
    Enumerator.new do |y|
      y << [
        I18n.t("helpers.legend.referees_can_give_reference_form.can_give_reference", name: referee.job_application.name),
        I18n.t("helpers.label.referees_can_give_reference_form.can_give_reference_options.#{reference.can_give_reference?}"),
      ]

      reference_rows(y) if can_give_reference?
    end
  end

  def candidate_ratings
    Enumerator.new do |y|
      JobReference::RATINGS_FIELDS_1.each { y << candidate_ratings_row(it, 1) }
      JobReference::RATINGS_FIELDS_2.each { y << candidate_ratings_row(it, 2) }
      JobReference::RATINGS_FIELDS_3.each { y << candidate_ratings_row(it, 3) }
    end
  end

  def candidate_name
    referee.job_application.name
  end

  def header_text
    "Reference"
  end

  def footer_text
    "#{header_text} - #{candidate_name}"
  end

  private

  def reference_rows(yielder)
    yielder << [
      I18n.t("helpers.legend.referees_can_share_reference_form.is_reference_sharable", name: referee.job_application.name),
      I18n.t("helpers.label.referees_can_share_reference_form.is_reference_sharable_options.#{reference.is_reference_sharable?}"),
    ]

    REF_INFO.each { yielder << ref_info_row(it) }

    JobReference::REFERENCE_INFO_FIELDS.each do |field|
      yielder << reference_information_row(field)
      yielder << under_investigation_row if under_investigation?(field)
      yielder << warning_details_row if warning_details?(field)
      yielder << undertake_role_row if not_able_to_undertake_role?(field)
    end
  end

  def under_investigation?(field)
    field == :under_investigation && reference.under_investigation?
  end

  def under_investigation_row
    [
      I18n.t("publishers.vacancies.job_applications.reference_requests.reference.under_investigation_details"),
      reference.under_investigation_details,
    ]
  end

  def warning_details?(field)
    field == :warnings && reference.warnings?
  end

  def warning_details_row
    [
      I18n.t("publishers.vacancies.job_applications.reference_requests.reference.warning_details"),
      reference.warning_details,
    ]
  end

  def not_able_to_undertake_role?(field)
    field == :able_to_undertake_role && !reference.able_to_undertake_role?
  end

  def undertake_role_row
    [
      I18n.t("publishers.vacancies.job_applications.reference_requests.reference.warning_details"),
      reference.unable_to_undertake_reason,
    ]
  end

  def referee_details_row(field)
    [
      I18n.t(field, scope: "publishers.vacancies.job_applications.reference_requests.show.referee_details"),
      referee[field],
    ]
  end

  def label(field, value)
    case value
    in Date
      value.to_fs
    in TrueClass | FalseClass
      I18n.t("helpers.label.referees_employment_reference_form.#{field}_options.#{value}")
    else
      value
    end
  end

  def reference_reason(field)
    reference["#{field}_reason"]
  end

  def ref_info_row(field)
    [
      I18n.t(field, scope: "helpers.legend.referees_employment_reference_form"),
      [label(field, reference[field]), reference_reason(field)].compact.join(", "),
    ]
  end

  def reference_information_row(field)
    [
      I18n.t(field, scope: "helpers.legend.referees_reference_information_form"),
      I18n.t("#{field}_options.#{reference[field]}", scope: "helpers.label.referees_reference_information_form"),
    ]
  end

  def candidate_ratings_row(field, form_number)
    [
      I18n.t(field, scope: "helpers.legend.referees_how_would_you_rate_form#{form_number}"),
      I18n.t("#{field}_options.#{reference[field]}", scope: "helpers.label.referees_how_would_you_rate_form#{form_number}"),
    ]
  end
end
