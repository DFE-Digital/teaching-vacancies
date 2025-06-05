class Jobseekers::BaseController < ApplicationController
  include ReturnPathTracking
  include Authenticated

  self.authentication_scope = :jobseeker
end
