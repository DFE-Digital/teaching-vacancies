module CommuteTimesHelper
  def commute_time_duration(minutes)
    hours, remaining_minutes = minutes.divmod(60)
    return t("jobs.commute_time_minutes", count: remaining_minutes) if hours.zero?
    return t("jobs.commute_time_hours", count: hours) if remaining_minutes.zero?

    t(
      "jobs.commute_time_hours_and_minutes",
      hours: t("jobs.commute_time_hours", count: hours),
      minutes: t("jobs.commute_time_minutes", count: remaining_minutes),
    )
  end
end
