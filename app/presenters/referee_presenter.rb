class RefereePresenter < BasePresenter
  REFEREE_DETAILS = %i[name job_title organisation relationship email phone_number].freeze

  alias_method :referee, :model

  def initialize(referee)
    super
    @reference = referee.reference_request.job_reference
  end

  attr_reader :reference

  delegate :can_give_reference?, to: :reference

  def referee_details
    Enumerator.new do |y|
      REFEREE_DETAILS.each { y << referee_details_row(it) }
    end
  end

  def reference_information
    Enumerator.new do |y|
      y << [
        I18n.t("helpers.legend.referees_can_give_reference_form.can_give_reference", name: candidate_name),
        I18n.t("helpers.label.referees_can_give_reference_form.can_give_reference_options.#{reference.can_give_reference?}"),
      ]

      if can_give_reference?
        y << [
          I18n.t("helpers.legend.referees_can_share_reference_form.is_reference_sharable", name: candidate_name),
          I18n.t("helpers.label.referees_can_share_reference_form.is_reference_sharable_options.#{reference.is_reference_sharable?}"),
        ]

        y << [
          I18n.t("helpers.label.referees_employment_reference_form.how_do_you_know_the_candidate"),
          reference.how_do_you_know_the_candidate,
        ]

        reference_rows(y)
      end
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

  # allegations and not fit to practice don't have reason fields to go with them.
  # as these need to be reported outside the service to the TRA.
  WARNING_FIELDS = {
    under_investigation: ->(reference) { under_investigation_row(reference) if reference.under_investigation? },
    warnings: ->(reference) { warning_details_row(reference) if reference.warnings? },
    allegations: ->(_reference) {},
    not_fit_to_practice: ->(_reference) {},
    able_to_undertake_role: ->(reference) { undertake_role_row(reference) unless reference.able_to_undertake_role? },
  }.freeze

  REFERENCE_INFORMATION_FIELDS = {
    employment_start_date: ->(reference) { reference.employment_start_date.to_fs },
    currently_employed: lambda { |reference|
      I18n.t("helpers.label.referees_employment_reference_form.currently_employed_options.#{reference.currently_employed}")
    },
    employment_end_date: ->(reference) { reference.employment_end_date.to_fs },
    would_reemploy_current: lambda { |reference|
      [
        I18n.t("helpers.label.referees_employment_reference_form.would_reemploy_current_options.#{reference.would_reemploy_current}"),
        reference.would_reemploy_current_reason,
      ].join(", ")
    },
    would_reemploy_any: lambda { |reference|
      [
        I18n.t("helpers.label.referees_employment_reference_form.would_reemploy_any_options.#{reference.would_reemploy_any}"),
        reference.would_reemploy_any_reason,
      ].join(", ")
    },
  }.freeze

  private

  def reference_rows(yielder)
    reference_fields = if reference.currently_employed?
                         REFERENCE_INFORMATION_FIELDS.except(:employment_end_date)
                       else
                         REFERENCE_INFORMATION_FIELDS
                       end

    reference_fields.each do |key, value|
      yielder << [
        I18n.t(key, scope: "helpers.legend.referees_employment_reference_form"),
        value.call(reference),
      ]
    end

    JobReference::REFERENCE_INFO_FIELDS.each do |field|
      yielder << reference_information_row(field)
      data_row = WARNING_FIELDS.fetch(field).call(reference)
      yielder << data_row if data_row.present?
    end
  end

  class << self
    def under_investigation_row(reference)
      [
        I18n.t("publishers.vacancies.job_applications.reference_requests.reference.under_investigation_details"),
        reference.under_investigation_details,
      ]
    end

    def warning_details_row(reference)
      [
        I18n.t("publishers.vacancies.job_applications.reference_requests.reference.warning_details"),
        reference.warning_details,
      ]
    end

    def undertake_role_row(reference)
      [
        I18n.t("publishers.vacancies.job_applications.reference_requests.reference.unable_to_undertake_role_details"),
        reference.unable_to_undertake_reason,
      ]
    end
  end

  def referee_details_row(field)
    [
      I18n.t(field, scope: "publishers.vacancies.job_applications.reference_requests.show.referee_details"),
      referee.public_send(field),
    ]
  end

  def reference_information_row(field)
    [
      I18n.t(field, scope: "helpers.legend.referees_reference_information_form"),
      I18n.t("#{field}_options.#{reference.public_send(field)}", scope: "helpers.label.referees_reference_information_form"),
    ]
  end

  def candidate_ratings_row(field, form_number)
    [
      I18n.t(field, scope: "helpers.legend.referees_how_would_you_rate_form#{form_number}"),
      I18n.t("#{field}_options.#{reference.public_send(field)}", scope: "helpers.label.referees_how_would_you_rate_form#{form_number}"),
    ]
  end
end
