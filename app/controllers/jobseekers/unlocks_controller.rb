class Jobseekers::UnlocksController < Devise::UnlocksController
  def show
    super if request.method == "POST"
  end
end
