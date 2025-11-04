class SelfDisclosureRequest < ApplicationRecord
  belongs_to :job_application
  has_one :self_disclosure, dependent: :destroy

  enum :status, { manual: 0, received_off_service: 1, sent: 2, received: 3 }

  has_paper_trail

  validates :job_application_id, uniqueness: true

  class << self
    def create_for!(job_application)
      find_or_create_by!(job_application: job_application) do |req|
        req.status = :manual
      end
    end

    def create_and_notify!(job_application)
      request = job_application.self_disclosure_request
      if request.present?
        request.update!(status: :sent)
      else
        request = job_application.create_self_disclosure_request!(status: :sent)
      end
      SelfDisclosure.find_or_create_by_and_prefill!(job_application)
      Jobseekers::SelfDisclosureRequestReceivedNotifier.with(record: request)
                                                .deliver
    end
  end

  def send_reminder!
    Jobseekers::SelfDisclosureRequestReceivedNotifier.with(record: itself).deliver
    touch
  end

  def pending?
    manual? || sent?
  end

  def has_been_received?
    received? || received_off_service?
  end
end
