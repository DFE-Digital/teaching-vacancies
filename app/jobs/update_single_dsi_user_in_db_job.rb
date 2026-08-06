# frozen_string_literal: true

class UpdateSingleDSIUserInDbJob < ApplicationJob
  queue_as :low

  # Race conditions may result in validation failures due to duplicates
  retry_on ActiveModel::ValidationError

  def perform(dsi_user)
    Publishers::DfeSignIn::UpdateUsersInDb.convert_to_user(dsi_user)
  end
end
