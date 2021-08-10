class Jobseeker < ApplicationRecord
  encrypts :last_sign_in_ip, :current_sign_in_ip

  # remove this line after dropping unencrypted columns
  self.ignored_columns = %w[last_sign_in_ip current_sign_in_ip]

  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :confirmable, :lockable, :trackable, :timeoutable

  has_many :feedbacks
  has_many :job_applications, dependent: :destroy
  has_many :saved_jobs, dependent: :destroy
end
