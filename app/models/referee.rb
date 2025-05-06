class Referee < ApplicationRecord
  self.table_name = "references"

  belongs_to :job_application
  has_one :job_reference, foreign_key: :reference_id, inverse_of: :referee

  has_encrypted :name, :job_title, :organisation, :email, :phone_number

  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid
end
