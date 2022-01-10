class VacancyReviewComponent::Section < ReviewComponent::Section
  include VacanciesHelper

  def initialize(vacancy, forms: [], show_errors: false, back_to: nil, classes: [], html_attributes: {}, **kwargs)
    super(
      vacancy,
      forms:,
      classes:,
      html_attributes:,
      **kwargs,
    )

    @back_to = back_to
    @show_errors = show_errors
    @vacancy = vacancy
  end

  private

  def heading_text
    t("publishers.vacancies.steps.#{@name}")
  end

  def build_list
    list = nil
    validatable_summary_list(@vacancy, show_errors: @show_errors, error_path:) { |l| list = l }
    list
  end

  def constantize_form(form_class_name)
    "Publishers::JobListing::#{form_class_name}".constantize
  end

  def error_path(**params)
    url_helpers.organisation_job_build_path(@vacancy.id, @name, back_to: @back_to, **params)
  end

  def error_link_text
    t("buttons.change")
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
