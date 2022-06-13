class SupportUsers::BaseController < ApplicationController
  include ReturnPathTracking
  include Authenticated

  layout "application_supportal"

  self.authentication_scope = :support_user
end
