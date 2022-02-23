class SupportUsers::BaseController < ApplicationController
  include ReturnPathTracking
  include Authenticated

  self.authentication_scope = :support_user
end
