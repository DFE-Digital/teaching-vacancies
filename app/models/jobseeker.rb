class Jobseeker < ApplicationRecord
  encrypts :last_sign_in_ip, :current_sign_in_ip, migrating: true

  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :confirmable, :lockable, :trackable, :timeoutable

  has_many :feedbacks
  has_many :job_applications, dependent: :destroy
  has_many :saved_jobs, dependent: :destroy
end
