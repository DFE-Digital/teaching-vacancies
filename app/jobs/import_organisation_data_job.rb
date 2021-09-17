require "organisation_import/import_school_data"
require "organisation_import/import_trust_data"

class ImportOrganisationDataJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    Rollbar.log(:info, "Mark all school_group_memberships to be deleted")
    ImportOrganisationData.mark_all_school_group_memberships_to_be_deleted!
    Rollbar.log(:info, "Start importing school and local autorities")
    ImportSchoolData.new.run!
    Rollbar.log(:info, "Start importing trusts")
    ImportTrustData.new.run!
    Rollbar.log(:info, "Delete marked school_group_memberships")
    ImportOrganisationData.delete_marked_school_group_memberships!
  end
end
