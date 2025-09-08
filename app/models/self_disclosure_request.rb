class SelfDisclosureRequest < ApplicationRecord
  include InterviewingRequest

  has_paper_trail

  belongs_to :job_application
  has_one :self_disclosure, dependent: :destroy

  validates :job_application_id, uniqueness: true

  class << self
    def create_for!(job_application)
      # External flow
      find_or_create_by!(job_application:) { it.status = :created }
    end

    def create_and_notify!(job_application)
      # Internal flow
      find_or_create_by!(job_application:).tap { it.update!(status: :requested) }
      SelfDisclosure.find_or_create_by_and_prefill!(job_application)
      Jobseekers::JobApplicationMailer.self_disclosure(job_application).deliver_later
    end
  end
end
