# frozen_string_literal: true

class BatchableJobApplication < ApplicationRecord
  belongs_to :job_application_batch

  belongs_to :job_application
end
