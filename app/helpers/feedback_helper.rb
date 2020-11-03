module FeedbackHelper
  def visit_purpose_options
    [[t("general_feedback.visit_purpose_options.find_teaching_job"), :find_teaching_job],
     [t("general_feedback.visit_purpose_options.list_teaching_job"), :list_teaching_job],
     [t("general_feedback.visit_purpose_options.other_purpose"), :other_purpose]]
  end

  def rating_options
    [[t("feedback.rating5_option"), 5],
     [t("feedback.rating4_option"), 4],
     [t("feedback.rating3_option"), 3],
     [t("feedback.rating2_option"), 2],
     [t("feedback.rating1_option"), 1]]
  end
end
