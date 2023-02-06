require 'multistep/controller'

module Jobseekers::Profiles
  class JobPreferencesController < ApplicationController
    include Multistep::Controller

    multistep_form Jobseekers::JobPreferencesForm, key: :job_preferences
    escape_path { jobseekers_profile_path }
  end
end
