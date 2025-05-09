# frozen_string_literal: true

module AssociatedRecord
  extend ActiveSupport::Concern

  included do
    belongs_to :job_application, optional: true
    belongs_to :jobseeker_profile, optional: true

    validates :job_application, presence: true, unless: -> { jobseeker_profile.present? }
    validates :job_application, absence: true, if: -> { jobseeker_profile.present? }

    validates :jobseeker_profile, presence: true, unless: -> { job_application.present? }
    validates :jobseeker_profile, absence: true, if: -> { job_application.present? }
  end

  def duplicate
    # dup does a shallow copy, but although it "doesn't copy associations" according to the
    # docs, it *does* copy parent associations so we remove these
    dup.tap do |record|
      record.assign_attributes(job_application: nil, jobseeker_profile: nil)
    end
  end
end
