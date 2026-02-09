class Publisher < ApplicationRecord
  has_many :emergency_login_keys, as: :owner
  has_many :feedbacks, dependent: :destroy, inverse_of: :publisher
  has_many :notes, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :organisation_publishers, dependent: :destroy
  has_many :organisations, through: :organisation_publishers
  has_many :publisher_preferences, dependent: :destroy
  has_many :vacancies
  has_many :publisher_messages, foreign_key: :sender_id, dependent: :destroy
  has_many :message_templates, dependent: :destroy

  has_encrypted :family_name, :given_name

  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid

  devise :timeoutable
  self.timeout_in = 120.minutes # Overrides default Devise configuration

  def vacancies_with_job_applications_submitted_yesterday
    vacancies.distinct
             .joins(:job_applications)
             .merge(JobApplication.submitted)
             .where("DATE(job_applications.submitted_at) = ?", Date.yesterday)
  end

  def papertrail_display_name
    "#{given_name} #{family_name}"
  end

  def accessible_organisations(current_organisation)
    return [] unless current_organisation

    if (publisher_preference = publisher_preferences.find_by(organisation: current_organisation))
      if current_organisation.local_authority?
        publisher_preference.schools
      else
        current_organisation.all_organisations
      end
    else
      current_organisation.all_organisations
    end
  end
end
