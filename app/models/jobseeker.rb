class Jobseeker < ApplicationRecord
  encrypts :email, :unconfirmed_email, migrating: true
  # blind index needed for searching by encrypted columns with .where/.find_by, and for validating uniqueness.
  blind_index :email, :unconfirmed_email, migrating: true

  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :confirmable, :lockable, :trackable, :timeoutable

  has_many :feedbacks
  has_many :job_applications, dependent: :destroy
  has_many :saved_jobs, dependent: :destroy
end
