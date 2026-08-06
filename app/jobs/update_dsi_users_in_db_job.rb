# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class UpdateDSIUsersInDbJob < ApplicationJob
  queue_as :low

  def perform
    Publishers::DfeSignIn::FetchDSIUsers.new.dsi_users.each { |page| convert_to_users(page) }
  end

  private

  def convert_to_users(api_users)
    api_users.each do |dsi_user|
      UpdateSingleDSIUserInDbJob.perform_later(dsi_user)
    end
  end
end
