class Referee < ApplicationRecord
  self.table_name = "references"

  belongs_to :job_application
  has_one :reference_request, foreign_key: :reference_id, inverse_of: :referee, dependent: :destroy

  has_encrypted :name, :job_title, :organisation, :email, :phone_number

  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid

  def duplicate
    # dup does a shallow copy, but although it "doesn't copy associations" according to the
    # docs, it *does* copy parent associations so we remove these
    dup.tap do |record|
      record.assign_attributes(job_application: nil)
    end
  end
end
