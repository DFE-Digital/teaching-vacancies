class SelfDisclosureRequest < ApplicationRecord
  belongs_to :job_application
  has_one :self_disclosure

  enum :status, { manual: 0, manually_completed: 1, sent: 2, received: 3 }

  has_paper_trail

  validates :job_application_id, uniqueness: true

  def self.create_all!(job_applications)
    job_applications.map do
      find_or_create_by!(job_application_id: it.id).tap(&:manual!)
    end
  end

  def self.create_and_notify_all!(job_applications)
    transaction do
      job_applications.map do |job_application|
        find_or_create_by!(job_application_id: job_application.id).tap do |request|
          job_application.self_disclosure_request = request
          SelfDisclosure.find_or_create_by_and_prefill!(job_application)
          Jobseekers::JobApplicationMailer.declarations(job_application).deliver_later
          request.sent!
        end
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
