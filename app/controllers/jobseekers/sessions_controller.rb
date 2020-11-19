class Jobseekers::SessionsController < Devise::SessionsController
  def create
    super do
      # Devise adds a :notice flash on login, we want it to be a :success flash
      flash[:success] = flash.discard(:notice)
    end
  end
end
