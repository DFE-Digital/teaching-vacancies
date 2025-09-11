module Jobseekers
  class BaseController < ApplicationController
    include ReturnPathTracking
    include LoginRequired
  end
end
