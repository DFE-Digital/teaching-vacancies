class ReferenceRequest < ApplicationRecord
  belongs_to :referee, foreign_key: :reference_id, inverse_of: :reference_request
  has_one :job_reference, dependent: :destroy

  validates :reference_id, uniqueness: true

  # marked_as_complete is a separate field as it can be done
  # even when the request is in the 'created' state as the hiring
  # staff can process references outside the service, but still mark
  # the request as complete when they receive it.
  enum :status, { created: 0, requested: 1, received: 2, received_off_service: 3 }

  validates :status, presence: true
  validates :token, :email, presence: true, unless: -> { received_off_service? }

  # expire token after 12 weeks
  scope :active_token, ->(token) { where(token: token, created_at: 12.weeks.ago..) }

  has_one_attached :reference_form

  def sent?
    requested? || received?
  end

  has_paper_trail skip: [:token]

  # change the referee email address - so re-regenerate the token
  def change_referee_email!(email)
    update!(email: email, token: SecureRandom.uuid)
    referee.update!(email: email)
    Publishers::CollectReferencesMailer.collect_references(self).deliver_later
  end

  def resend_email
    update!(reminder_sent: true)
    Publishers::CollectReferencesMailer.collect_references(self).deliver_later
  end

  def can_send_reminder?
    requested? && updated_at <= 7.days.ago
  end

  # Interface called by ActiveStorage::Blob (MalwareScannable) when this record's
  # reference_form blob is found unsafe. Destroys the referee and notifies the
  # publisher. Each model that owns scannable attachments defines its own.
  def handle_unsafe_attachment(_attachment)
    job_application = referee.job_application
    vacancy = job_application.vacancy

    referee.destroy!

    if vacancy.find_publisher_by_contact_email
      Publishers::ReferenceDocumentMalwareScanNotifier.with(job_application: job_application).deliver
    else
      Publishers::ReferenceDocumentMalwareScanMailer.reference_removed(job_application).deliver_later
    end
  end

  class << self
    def create_for_manual!(job_application)
      job_application.referees.reject { |r| r.reference_request.present? }.each do |referee|
        referee.create_reference_request!(token: SecureRandom.uuid, status: :created, email: referee.email)
      end
    end

    def create_for_external!(job_application)
      job_application.referees.each do |referee|
        create_external_for_referee!(referee)
      end
    end

    def create_external_for_referee!(referee)
      reference_request = create_reference_request!(referee)
      reference_request.create_job_reference!
      Publishers::CollectReferencesMailer.collect_references(reference_request).deliver_later
    end

    private

    def create_reference_request!(referee)
      if referee.reference_request.present?
        referee.reference_request.tap do |rr|
          rr.update!(status: :requested)
        end
      else
        referee.create_reference_request!(token: SecureRandom.uuid, status: :requested, email: referee.email)
      end
    end
  end
end
