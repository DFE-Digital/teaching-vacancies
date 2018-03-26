class HiringStaff::SessionsController < HiringStaff::BaseController
  before_action :authenticate, except: [:destroy]

  def new
    # User is routed to this action where basic authentication is listening for all requests
    redirect_to school_path(current_school.id)
  end
end
