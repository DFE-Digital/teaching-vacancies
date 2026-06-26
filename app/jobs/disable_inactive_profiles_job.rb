class DisableInactiveProfilesJob < ApplicationJob
  queue_as :low

  def perform
    Jobseeker.includes(:jobseeker_profile)
             .active
             .where(last_sign_in_at: ..6.months.ago)
             .find_each
             .filter_map(&:jobseeker_profile)
             .select(&:active?)
             .each do |jsp|
               jsp.assign_attributes(active: false)
               jsp.save!(touch: false)

               Jobseekers::ProfilesMailer.disable_inactive_profile(jsp).deliver_later
    end
  end
end
