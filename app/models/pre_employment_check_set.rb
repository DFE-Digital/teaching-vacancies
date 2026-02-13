# frozen_string_literal: true

class PreEmploymentCheckSet < ApplicationRecord
  belongs_to :job_application

  validates :job_application, uniqueness: true
end
