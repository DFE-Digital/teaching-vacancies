class RefreshOrganisationsGiasDataHashJob < ApplicationJob
  def perform
    Organisation.find_each(&:refresh_gias_data_hash)
  end
end
