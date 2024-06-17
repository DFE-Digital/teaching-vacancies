class Publisher < ApplicationRecord
  has_many :emergency_login_keys
  has_many :feedbacks, dependent: :destroy, inverse_of: :publisher
  has_many :notes, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :organisation_publishers, dependent: :destroy
  has_many :organisations, through: :organisation_publishers
  has_many :publisher_preferences, dependent: :destroy
  has_many :vacancies

  has_encrypted :family_name, :given_name

  devise :timeoutable
  self.timeout_in = 120.minutes # Overrides default Devise configuration

  def vacancies_with_job_applications_submitted_yesterday
    vacancies.distinct
             .joins(:job_applications)
             .where("DATE(job_applications.submitted_at) = ? AND job_applications.status = ?", Date.yesterday, 1)
  end

  def papertrail_display_name
    "#{given_name} #{family_name}"
  end
end
