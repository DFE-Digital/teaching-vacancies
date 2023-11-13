class Jobseekers::UnlocksController < Devise::UnlocksController
  def show
    if request.method == "POST"
      super
    else
      enc_token = Devise.token_generator.digest(Jobseeker, :unlock_token, params[:unlock_token])
      super unless Jobseeker.find_by(unlock_token: enc_token)
    end
  end
end
