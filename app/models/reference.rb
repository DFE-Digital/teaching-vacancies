class Reference < ApplicationRecord
  belongs_to :job_application

  has_encrypted :name, :job_title, :organisation, :email, :phone_number
end
