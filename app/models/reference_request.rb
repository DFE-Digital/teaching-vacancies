class ReferenceRequest < ApplicationRecord
  validates :token, presence: true

  belongs_to :referee, foreign_key: :reference_id, inverse_of: :reference_request
  has_one :job_reference, dependent: :destroy

  validates :reference_id, uniqueness: true

  # marked_as_complete is a separate field as it can be done
  # even when the request is in the 'created' state as the hiring
  # staff can process references outside the service, but still mark
  # the request as complete when they receive it.
  enum :status, { created: 0, requested: 1, received: 2, received_off_service: 3 }

  validates :status, :email, presence: true

  # expire token after 12 weeks
  scope :active_token, ->(token) { where(token: token, created_at: 12.weeks.ago..) }

  def sent?
    !created? && !received_off_service?
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

  class << self
    def create_for_manual!(job_application)
      job_application.referees.reject { |r| r.reference_request.present? }.each do |referee|
        referee.create_reference_request!(token: SecureRandom.uuid, status: :created, email: referee.email)
      end
    end

    def create_for_external!(job_application)
      job_application.referees.each do |referee|
        reference_request = create_reference_request!(referee)
        reference_request.create_job_reference!
        Publishers::CollectReferencesMailer.collect_references(reference_request).deliver_later
      end
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
