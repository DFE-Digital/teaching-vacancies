class InactiveProfileWarningsJob < ApplicationJob
  queue_as :low

  def perform
    send_warnings_from(5.months.ago)
    send_warnings_from(6.months.ago + 2.weeks)
  end

  private

  def send_warnings_from(date)
    next_date = date + 1.day
    Jobseeker.includes(:jobseeker_profile)
             .active
             .where(last_sign_in_at: date..next_date)
             .find_each
             .filter_map(&:jobseeker_profile)
             .select(&:active?)
             .each do |jsp|
      Jobseekers::ProfilesMailer.inactive_profile_warning(jsp).deliver_later
    end
  end
end
