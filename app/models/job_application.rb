class JobApplication < ApplicationRecord
  enum status: { draft: 0, submitted: 1 }

  belongs_to :jobseeker
  belongs_to :vacancy

  has_many :job_application_details
  has_many :employment_history, -> { where(details_type: "employment_history") }, class_name: "JobApplicationDetail"
  has_many :references, -> { where(details_type: "references") }, class_name: "JobApplicationDetail"
end
