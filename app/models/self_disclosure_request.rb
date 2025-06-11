class SelfDisclosureRequest < ApplicationRecord
  belongs_to :job_application
  has_one :self_disclosure

  enum :status, { manual: 0, manually_completed: 1, sent: 2, received: 3 }

  has_paper_trail

  validates :job_application_id, uniqueness: true

  class << self
    def create_for!(job_application)
      find_or_create_by!(job_application: job_application).tap(&:manual!)
    end

    def create_and_notify!(job_application)
      find_or_create_by!(job_application: job_application).tap do |request|
        SelfDisclosure.find_or_create_by_and_prefill!(job_application)
        Jobseekers::JobApplicationMailer.declarations(job_application).deliver_later
        request.sent!
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
