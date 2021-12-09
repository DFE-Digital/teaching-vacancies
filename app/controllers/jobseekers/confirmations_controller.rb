class Jobseekers::ConfirmationsController < Devise::ConfirmationsController
  after_action :remove_devise_flash!, only: %i[create]

  def show
    super do |resource|
      unless resource.errors.empty?
        # Track which error type is causing 'Your request was invalid' issues for users.
        # This will be 'already_confirmed', 'confirmation_period_expired', 'invalid', or a combination.
        request_event.trigger(:invalid_confirmation_attempt,
                              errors: resource.errors.errors.map { |e| e.type.to_s },
                              resource_identifier: StringAnonymiser.new(resource.id).to_s,
                              email_identifier: StringAnonymiser.new(resource.email).to_s)
      end
    end
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    request_event.trigger(:jobseeker_email_confirmed)
    stored_location_for(resource_name) || jobseeker_root_path
  end

  def after_resending_confirmation_instructions_path_for(_resource)
    jobseekers_check_your_email_path
  end
end
