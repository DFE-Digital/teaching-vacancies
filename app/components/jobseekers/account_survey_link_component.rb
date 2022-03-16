class Jobseekers::AccountSurveyLinkComponent < ViewComponent::Base
  def initialize(origin:)
    @origin = origin
  end

  def link_to_survey
    govuk_button_link_to t(".survey_link_text"), new_jobseekers_account_feedback_path(origin: @origin)
  end
end
