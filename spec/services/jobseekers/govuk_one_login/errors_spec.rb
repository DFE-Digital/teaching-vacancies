require "rails_helper"

RSpec.describe Jobseekers::GovukOneLogin::Errors do
  describe Jobseekers::GovukOneLogin::Errors::GovukOneLoginError do
    it "provides a default error message" do
      expect { raise described_class }
        .to raise_error(Jobseekers::GovukOneLogin::Errors::GovukOneLoginError, "GovukOneLogin: Failed to authenticate with Govuk One Login")
    end

    it "allows to customize the error message based on title and description" do
      expect { raise described_class.new("Custom error", "error message") }
        .to raise_error(Jobseekers::GovukOneLogin::Errors::GovukOneLoginError, "Custom error: error message")
    end
  end

  [Jobseekers::GovukOneLogin::Errors::AuthenticationError,
   Jobseekers::GovukOneLogin::Errors::ClientRequestError,
   Jobseekers::GovukOneLogin::Errors::SessionKeyError,
   Jobseekers::GovukOneLogin::Errors::TokensError,
   Jobseekers::GovukOneLogin::Errors::IdTokenError,
   Jobseekers::GovukOneLogin::Errors::UserInfoError].each do |error_class|
    describe error_class do
      it "builds the error message based on the given title and description" do
        expect { raise described_class.new("Error title", "long description") }
          .to raise_error(error_class, "Error title: long description")
      end
    end
  end
end
