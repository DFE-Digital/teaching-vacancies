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
      request = job_application.self_disclosure_request
      if request.present?
        request.update!(status: :requested)
      else
        request = job_application.create_self_disclosure_request!(status: :requested)
      end

      SelfDisclosure.find_or_create_by_and_prefill!(job_application)
      Jobseekers::SelfDisclosureRequestReceivedNotifier.with(record: request)
                                                .deliver
    end
  end
end
