class ProfessionalBodyMembership < ApplicationRecord
  belongs_to :job_application

  def duplicate
    # dup does a shallow copy, but although it "doesn't copy associations" according to the
    # docs, it *does* copy parent associations so we remove these
    dup.tap do |record|
      record.assign_attributes(job_application: nil)
    end
  end
end
