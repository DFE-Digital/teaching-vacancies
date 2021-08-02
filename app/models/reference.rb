class Reference < ApplicationRecord
  belongs_to :job_application

  encrypts :name, :job_title, :organisation, :email, :phone_number
end
