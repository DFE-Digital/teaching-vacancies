class BatchEmail < ApplicationRecord
  has_many :batch_email_job_applications, dependent: :destroy
  has_many :job_applications, through: :batch_email_job_applications

  belongs_to :vacancy

  enum :batch_type, { not_sent: 0, rejection: 1 }
end
