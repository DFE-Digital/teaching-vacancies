class DisableActiveProfilesWithoutNewFieldsJob < ApplicationJob
  queue_as :low

  def perform
    Jobseeker.includes(:jobseeker_profile)
             .active
             .find_each
             .filter_map(&:jobseeker_profile)
             .select(&:active?)
             .reject(&:activable?)
             .each do |jsp|
      jsp.assign_attributes(active: false)
      jsp.save!(touch: false)

      Jobseekers::ProfilesMailer.disable_profile_due_to_new_fields(jsp).deliver_later
    end
  end
end
