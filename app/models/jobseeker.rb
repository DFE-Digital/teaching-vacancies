class Jobseeker < ApplicationRecord
  encrypts :last_sign_in_ip, :current_sign_in_ip

  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :confirmable, :lockable, :trackable, :timeoutable

  has_many :feedbacks
  has_many :job_applications, dependent: :destroy
  has_many :saved_jobs, dependent: :destroy

  after_update :update_subscription_emails

  def update_subscription_emails
    return unless saved_change_to_attribute?(:email)

    Subscription.where(email: email_previously_was).update(email:)
  end
end
