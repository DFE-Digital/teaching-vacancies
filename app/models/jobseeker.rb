class Jobseeker < ApplicationRecord
  encrypts :email, :unconfirmed_email, migrating: true
  blind_index :email, migrating: true # needed for validating uniqueness of encrypted columns

  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :confirmable, :lockable, :trackable, :timeoutable

  has_many :feedbacks
  has_many :job_applications, dependent: :destroy
  has_many :saved_jobs, dependent: :destroy
end
