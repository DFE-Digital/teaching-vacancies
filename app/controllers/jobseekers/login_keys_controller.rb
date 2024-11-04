class Jobseekers::LoginKeysController < AuthenticationController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  before_action :redirect_signed_in_jobseekers, only: %i[new create]
  before_action :redirect_for_one_login_authentication, only: %i[new create]
  before_action :check_login_key, only: %i[consume]

  def new
    flash.now[:notice] = t(".notice")
  end

  def create
    jobseeker = Jobseeker.find_by(email: params.dig(:jobseeker, :email).downcase.strip)
    send_login_key(jobseeker: jobseeker) if jobseeker
  end

  def consume
    @jobseeker = Jobseeker.find(@login_key.owner_id)

    if @jobseeker
      @login_key.destroy!
      sign_in(@jobseeker)
      trigger_jobseeker_sign_in_event(:success)
      redirect_to jobseeker_root_path
    else
      render(:new)
    end
  end

  private

  def check_login_key
    @login_key = EmergencyLoginKey.find_by(id: params[:id])
    failure = if @login_key.nil?
                "no_key"
              elsif @login_key.expired?
                "expired"
              end

    (render(:error, locals: { failure: }) and return) if failure.present?
  end

  def redirect_signed_in_jobseekers
    return unless jobseeker_signed_in? && current_jobseeker.present?

    redirect_to jobseeker_root_path
  end

  def redirect_for_one_login_authentication
    return if AuthenticationFallbackForJobseekers.enabled?

    redirect_to new_jobseeker_session_path
  end

  def send_login_key(jobseeker:)
    Jobseekers::AuthenticationFallbackMailer.sign_in_fallback(
      login_key_id: generate_login_key(jobseeker: jobseeker).id,
      jobseeker: jobseeker,
    ).deliver_later
  end

  def generate_login_key(jobseeker:)
    EmergencyLoginKey.create(owner: jobseeker, not_valid_after: Time.current + EMERGENCY_LOGIN_KEY_DURATION)
  end
end
