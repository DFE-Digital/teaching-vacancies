# frozen_string_literal: true

class EmploymentRecord < ApplicationRecord
  self.abstract_class = true

  MAIN_DUTIES_MAX_WORDS = 150
  REASON_FOR_LEAVING_MAX_WORDS = 50

  # This class represents 2 concerns - 'job' and 'break' (from employment)
  # which might have been better modelled as 2 different types
  enum :employment_type, { job: 0, break: 1 }

  validates :organisation, :job_title, presence: true, if: -> { job? }
  validates :main_duties_words, length: { maximum: MAIN_DUTIES_MAX_WORDS }, if: -> { main_duties.present? }
  validates :reason_for_leaving_words, length: { maximum: REASON_FOR_LEAVING_MAX_WORDS }, if: -> { reason_for_leaving.present? }

  validates :started_on, date: { before: :today }, if: -> { job? }

  validates :ended_on, date: { before: :today, on_or_after: :started_on }, unless: -> { is_current_role? }, if: -> { job? }
  validates :ended_on, absence: true, if: -> { job? && is_current_role? }

  private

  def main_duties_words
    main_duties.scan(/\w+/)
  end

  def reason_for_leaving_words
    reason_for_leaving.scan(/\w+/)
  end
end
