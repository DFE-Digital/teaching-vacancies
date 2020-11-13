module FeedbackHelper
  def visit_purpose_options
    [[t("general_feedback.visit_purpose_options.find_teaching_job"), :find_teaching_job],
     [t("general_feedback.visit_purpose_options.list_teaching_job"), :list_teaching_job],
     [t("general_feedback.visit_purpose_options.other_purpose"), :other_purpose]]
  end
end
