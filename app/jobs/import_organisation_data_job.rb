class ImportOrganisationDataJob < ApplicationJob
  queue_as :low

  def perform
    SchoolGroupMembership.mark_all_records_for_deletion

    Gias::ImportSchoolsAndLocalAuthorities.new.call
    Gias::ImportTrusts.new.call

    SchoolGroupMembership.delete_records_marked_for_deletion
  end
end
