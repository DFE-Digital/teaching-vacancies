class ImportOrganisationDataJob < ApplicationJob
  queue_as :low

  def perform
    SchoolGroupMembership.mark_all_records_for_deletion

    Gias::ImportSchoolsAndLocalAuthorities.new.call
    Gias::ImportTrusts.new.call

    # Note: Gias::ImportSchoolsAndLocalAuthorities.new.call updates most SchoolGroupMemberships so they are no longer marked for deletion. Only
    # the SchoolGroupMemberships that don't exist in the new import will still be marked for deletion.
    SchoolGroupMembership.delete_records_marked_for_deletion
  end
end
