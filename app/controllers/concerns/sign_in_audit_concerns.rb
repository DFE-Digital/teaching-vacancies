require "message_encryptor"
module SignInAuditConcerns
  extend ActiveSupport::Concern

  def audit_successful_authentication
    Auditor::Audit.new(nil, "dfe-sign-in.authentication.success", current_publisher_oid).log_without_association
  end

  def audit_successful_authorisation
    Auditor::Audit.new(current_organisation, "dfe-sign-in.authorisation.success", current_publisher_oid).log
  end

  def audit_failed_authorisation
    Auditor::Audit.new(nil, "dfe-sign-in.authorisation.failure", current_publisher_oid).log_without_association
  end
end
