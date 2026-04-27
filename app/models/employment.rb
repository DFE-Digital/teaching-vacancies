class Employment < EmploymentRecord
  belongs_to :job_application

  has_encrypted :organisation, :job_title, :main_duties

  # KSIE dictates that we need a reason_for_leaving even for current role
  validates :reason_for_leaving, :main_duties, presence: true, if: -> { job? }

  def duplicate
    # dup does a shallow copy, but although it "doesn't copy associations" according to the
    # docs, it *does* copy parent associations so we remove these
    dup.tap do |record|
      record.assign_attributes(job_application: nil)
    end
  end
end
