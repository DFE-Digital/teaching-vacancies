class AccountRequest < ApplicationRecord
  encrypts :email, :full_name, :organisation_name, :organisation_identifier
end
