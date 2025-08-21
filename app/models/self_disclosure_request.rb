class SelfDisclosureRequest < ApplicationRecord
  include Discard::Model

  belongs_to :job_application
  has_one :self_disclosure

  enum :status, { manual: 0, manually_completed: 1, sent: 2, received: 3 }

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
        job_application.create_self_disclosure_request!(status: :sent)
      end
      SelfDisclosure.find_or_create_by_and_prefill!(job_application)
      Jobseekers::JobApplicationMailer.self_disclosure(job_application).deliver_later
    end
  end

  def completed?
    manually_completed? || received?
  end

  def pending?
    manual? || sent?
  end
end
