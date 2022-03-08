class Authorisation
  ROLES = {
    publisher: ENV["DFE_SIGN_IN_PUBLISHER_ROLE_ID"],
    support_user: ENV["DFE_SIGN_IN_SUPPORT_USER_ROLE_ID"],
  }.freeze

  def initialize(dsi_client: nil, **kwargs)
    @dsi_client = dsi_client || DSIClient.new(**kwargs)
  end

  def authorised_publisher?
    authorised?(:publisher)
  end

  def authorised_support_user?
    authorised?(:support_user)
  end

  private

  def authorised?(role)
    @dsi_client.role_ids.include?(ROLES[role])
  rescue DSIClient::RequestInvalid
    false
  rescue DSIClient::RequestFailed => e
    raise ExternalServerError, e.message
  end

  class ExternalServerError < StandardError; end
end
