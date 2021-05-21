class Publishers::VacancyWizardBackLinkComponent < ViewComponent::Base
  def initialize(vacancy, previous_step_path: nil, current_step_is_first_step: false, review: false)
    @vacancy = vacancy
    @previous_step_path = previous_step_path
    @current_step_is_first_step = current_step_is_first_step
    @review = review
  end

  def render?
    @review || !current_step_is_first_step?
  end

  def call
    govuk_back_link(text: text, href: href)
  end

  private

  def text
    if @vacancy.published? || @review
      t("buttons.cancel_and_return")
    else
      t("buttons.back_to_previous_step")
    end
  end

  def href
    if @vacancy.published?
      edit_organisation_job_path(@vacancy.id)
    elsif @review
      organisation_job_review_path(@vacancy.id)
    else
      @previous_step_path
    end
  end

  def current_step_is_first_step?
    @current_step_is_first_step.present?
  end
end
