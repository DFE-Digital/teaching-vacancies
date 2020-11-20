class Jobseekers::ApplicationController < ApplicationController
  before_action :authenticate_jobseeker!
end
