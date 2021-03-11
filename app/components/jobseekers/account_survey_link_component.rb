class Jobseekers::AccountSurveyLinkComponent < ViewComponent::Base
  def initialize(origin:)
    @origin = origin
  end

  def link_to_survey
    link_to(
      t(".survey_link"),
      new_jobseekers_account_feedback_path(origin: @origin),
      id: "account-survey-link-sticky-gtm",
    )
  end
end
