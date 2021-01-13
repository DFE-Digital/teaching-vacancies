class Publishers::VacancyWizardBackLinkComponent < ViewComponent::Base
  def initialize(vacancy, previous_step_path: nil, current_step_is_first_step: false)
    @vacancy = vacancy
    @previous_step_path = previous_step_path
    @current_step_is_first_step = current_step_is_first_step
  end

  def render?
    !vacancy_is_in_create_state? || !current_step_is_first_step?
  end

  def call
    govuk_back_link(text: text, href: href)
  end

private

  def text
    if vacancy_is_in_create_state?
      t("buttons.back")
    else
      t("buttons.cancel_and_return")
    end
  end

  def href
    if vacancy_is_in_create_state?
      @previous_step_path
    elsif vacancy_is_published?
      edit_organisation_job_path(@vacancy.id)
    else
      organisation_job_review_path(@vacancy.id)
    end
  end

  def vacancy_is_in_create_state?
    @vacancy.state == "create"
  end

  def vacancy_is_published?
    @vacancy.published?
  end

  def current_step_is_first_step?
    @current_step_is_first_step.present?
  end
end
