class ProfessionalBodyMembership < ApplicationRecord
  belongs_to :job_application

  validates :name, presence: true
  validates :exam_taken, inclusion: { in: [true, false], allow_nil: false }

  def duplicate
    # dup does a shallow copy, but although it "doesn't copy associations" according to the
    # docs, it *does* copy parent associations so we remove these
    dup.tap do |record|
      record.assign_attributes(job_application: nil)
    end
  end
end
