class SelfDisclosureRequest < ApplicationRecord
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
      find_or_create_by!(job_application: job_application) { |request|
        request.status = :sent
      }.tap do
        SelfDisclosure.find_or_create_by_and_prefill!(job_application)
        Jobseekers::JobApplicationMailer.self_disclosure(job_application).deliver_later
      end
    end
  end

  def completed?
    manually_completed? || received?
  end

  def pending?
    manual? || sent?
  end
end
