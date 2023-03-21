class InvitationToApply < ApplicationRecord
  belongs_to :vacancy
  belongs_to :jobseeker
  belongs_to :invited_by, class_name: "Publisher"

  has_one :organisation, through: :vacancy
end
