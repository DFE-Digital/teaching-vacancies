# frozen_string_literal: true

class ReligiousReferenceRequest < ApplicationRecord
  belongs_to :job_application

  enum :status, { action_needed: 0, requested: 1, complete: 2 }

  validates :status, presence: true
  validates :job_application_id, uniqueness: true

  has_paper_trail
end
