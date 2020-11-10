require "message_encryptor"
module SignInAuditConcerns
  extend ActiveSupport::Concern

  def sign_in_event(status:)
    data = [Time.current.iso8601.to_s,
            user_dsi_id,
            selected_school_urn,
            identifier,
            status.to_s]

    MessageEncryptor.new(data).encrypt
  end

  def audit_successful_authentication
    Auditor::Audit.new(nil, "dfe-sign-in.authentication.success", current_session_id).log_without_association
  end

  def audit_successful_authorisation
    Auditor::Audit.new(current_organisation, "dfe-sign-in.authorisation.success", current_session_id).log
  end

  def audit_failed_authorisation
    Auditor::Audit.new(nil, "dfe-sign-in.authorisation.failure", current_session_id).log_without_association
  end

  def user_dsi_id
    oid || ""
  end
end
