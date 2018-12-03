require 'message_encryptor'
module SignInAuditConcerns
  extend ActiveSupport::Concern

  def sign_in_event(status:)
    data = [Time.zone.now.iso8601.to_s,
            user_dsi_id,
            selected_school_urn,
            identifier,
            status.to_s]

    MessageEncryptor.new(data).encrypt
  end

  def log_succesful_authentication
    Auditor::Audit.new(nil, 'dfe-sign-in.authentication.success', current_session_id).log_without_association
  end

  def log_succesful_authorisation
    Auditor::Audit.new(current_school, 'dfe-sign-in.authorisation.success', current_session_id).log
    AuditSignInEventJob.perform_later(sign_in_event(status: :successful_authorisation))
  end

  def log_failed_authorisation
    Auditor::Audit.new(nil, 'dfe-sign-in.authorisation.failure', current_session_id).log_without_association
    AuditSignInEventJob.perform_later(sign_in_event(status: :failed_authorisation))
    Rails.logger.warn("Hiring staff not authorised: #{oid} for school: #{selected_school_urn}")
  end

  def user_dsi_id
    oid || ''
  end
end
