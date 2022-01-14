class Reference < ApplicationRecord
  belongs_to :job_application

  lockbox_encrypts :name, :job_title, :organisation, :email, :phone_number
end
