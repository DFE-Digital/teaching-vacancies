class Jobseeker < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :confirmable, :lockable, :trackable, :timeoutable

  has_many :saved_jobs, dependent: :destroy

  has_many :account_feedbacks, dependent: :destroy
end
