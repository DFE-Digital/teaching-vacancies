class Employment < EmploymentRecord
  MAIN_DUTIES_MAX_WORDS = 150
  REASON_FOR_LEAVING_MAX_WORDS = 50

  belongs_to :job_application

  has_encrypted :organisation, :job_title, :main_duties

  # KSIE dictates that we need a reason_for_leaving even for current role
  validates :reason_for_leaving, :main_duties, presence: true, if: -> { job? }
  validate :main_duties_does_not_exceed_maximum_words, if: -> { main_duties.present? }
  validate :reason_for_leaving_does_not_exceed_maximum_words, if: -> { reason_for_leaving.present? }

  def duplicate
    # dup does a shallow copy, but although it "doesn't copy associations" according to the
    # docs, it *does* copy parent associations so we remove these
    dup.tap do |record|
      record.assign_attributes(job_application: nil)
    end
  end

  private

  def main_duties_does_not_exceed_maximum_words
    return if main_duties_words.length <= MAIN_DUTIES_MAX_WORDS

    errors.add(:main_duties, :too_long, count: MAIN_DUTIES_MAX_WORDS)
  end

  def reason_for_leaving_does_not_exceed_maximum_words
    return if reason_for_leaving_words.length <= REASON_FOR_LEAVING_MAX_WORDS

    errors.add(:reason_for_leaving, :too_long, count: REASON_FOR_LEAVING_MAX_WORDS)
  end

  def main_duties_words
    main_duties.strip.split(/\s+/)
  end

  def reason_for_leaving_words
    reason_for_leaving.strip.split(/\s+/)
  end
end
