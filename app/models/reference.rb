class Reference < ApplicationRecord
  belongs_to :job_application

  encrypts :name, :job_title, :organisation, :email, :phone_number

  # remove this line after dropping unencrypted columns
  self.ignored_columns = %w[name job_title organisation email phone_number]
end
