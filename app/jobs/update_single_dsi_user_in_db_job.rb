# frozen_string_literal: true

class UpdateSingleDSIUserInDbJob < ApplicationJob
  def perform(dsi_user)
    Publishers::DfeSignIn::UpdateUsersInDb.new.convert_to_user(dsi_user)
  end
end
