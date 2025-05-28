# frozen_string_literal: true

class JobApplicationBatch < ApplicationRecord
  belongs_to :vacancy

  has_many :batchable_job_applications, dependent: :destroy
end
