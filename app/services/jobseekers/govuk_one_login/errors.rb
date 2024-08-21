module Jobseekers::GovukOneLogin::Errors
  class GovukOneLoginError < StandardError
    def initialize(error = "GovukOneLogin", description = "Failed to authenticate with Govuk One Login")
      super("#{error}: #{description}")
    end
  end

  class ClientRequestError < GovukOneLoginError; end
  class AuthenticationError < GovukOneLoginError; end
  class SessionKeyError < GovukOneLoginError; end
  class TokensError < GovukOneLoginError; end
  class IdTokenError < GovukOneLoginError; end
  class UserInfoError < GovukOneLoginError; end
end
