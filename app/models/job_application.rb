class JobApplication < ApplicationRecord
  enum status: { draft: 0, submitted: 1 }

  belongs_to :jobseeker
  belongs_to :vacancy

  has_many :job_application_details
  has_many :references, -> { where(details_type: "references") }, class_name: "JobApplicationDetail"
end
