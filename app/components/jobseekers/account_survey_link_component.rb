class Jobseekers::AccountSurveyLinkComponent < ViewComponent::Base
  def initialize(back_link:)
    @back_link = back_link
  end

  def link_to_survey
    link_to(
      I18n.t("jobseekers.accounts.footer.survey_link"),
      new_jobseekers_account_feedback_path(back_link: @back_link),
      id: "account-survey-link-sticky-gtm",
    )
  end
end
