class SelfDisclosure < ApplicationRecord
  belongs_to :job_application

  has_encrypted :name, :previous_names, :address_line_1, :address_line_2, :city, :county, :postcode,
                :phone_number, :signature
  has_encrypted :date_of_birth, type: :date
  has_encrypted :has_unspent_convictions, :has_spent_convictions, :is_barred, :has_been_referred,
                :is_known_to_children_services, :has_been_dismissed, :has_been_disciplined,
                :has_been_disciplined_by_regulatory_body, :agreed_for_processing,
                :agreed_for_criminal_record, :agreed_for_organisation_update,
                :agreed_for_information_sharing, type: :boolean

  # personal details
  validates :name, presence: true, on: :personal_details
  validates :address_line_1, presence: true, on: :personal_details
  validates :city, presence: true, on: :personal_details
  validates :postcode, presence: true, on: :personal_details
  validates :phone_number, presence: true, on: :personal_details
  validates :date_of_birth, presence: true, on: :personal_details
  validates :has_unspent_convictions, inclusion: { in: [true, false] }, on: :personal_details
  validates :has_spent_convictions, inclusion: { in: [true, false] }, on: :personal_details

  # barred list
  validates :is_barred, inclusion: { in: [true, false] }, on: :barred_list
  validates :has_been_referred, inclusion: { in: [true, false] }, on: :barred_list

  # conduct
  validates :is_known_to_children_services, inclusion: { in: [true, false] }, on: :conduct
  validates :has_been_dismissed, inclusion: { in: [true, false] }, on: :conduct
  validates :has_been_disciplined, inclusion: { in: [true, false] }, on: :conduct
  validates :has_been_disciplined_by_regulatory_body, inclusion: { in: [true, false] }, on: :conduct

  # confirmation
  validates :agreed_for_processing, presence: true, on: :confirmation
  validates :agreed_for_criminal_record, presence: true, on: :confirmation
  validates :agreed_for_organisation_update, presence: true, on: :confirmation
  validates :agreed_for_information_sharing, presence: true, on: :confirmation
  validates :signature, presence: true, on: :confirmation
end
