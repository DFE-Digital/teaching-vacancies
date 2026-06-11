class RefreshOrganisationsGiasDataHashJob < SidekiqJob
  def perform
    Organisation.find_each(&:refresh_gias_data_hash)
  end
end
