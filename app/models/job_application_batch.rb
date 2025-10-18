# frozen_string_literal: true

class JobApplicationBatch < ApplicationRecord
  belongs_to :vacancy

  has_many :batchable_job_applications, dependent: :destroy
  has_many :job_applications, through: :batchable_job_applications
end
