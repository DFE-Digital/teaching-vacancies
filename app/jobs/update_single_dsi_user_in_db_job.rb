# frozen_string_literal: true

class UpdateSingleDSIUserInDbJob < ApplicationJob
  queue_as :low

  def perform(dsi_user)
    Publishers::DfeSignIn::UpdateUsersInDb.convert_to_user(dsi_user)
  end
end
