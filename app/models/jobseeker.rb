class Jobseeker < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :confirmable, :lockable, :trackable, :timeoutable

  has_many :saved_jobs, dependent: :destroy

  has_many :job_applications, dependent: :destroy
end
