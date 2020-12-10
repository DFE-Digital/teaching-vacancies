module Publishers::SchoolsHelper
  def awaiting_feedback_tab(count)
    if count.zero?
      t("jobs.awaiting_feedback_jobs")
    else
      content_tag :span do
        content_tag(:span, t("jobs.awaiting_feedback_jobs")) +
          content_tag(:span, count, class: "notification", data: { test: "expired-vacancies-with-feedback-outstanding" })
      end
    end
  end
end
