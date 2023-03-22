class InvitationToApply < ApplicationRecord
  belongs_to :vacancy
  belongs_to :jobseeker
  belongs_to :invited_by, class_name: "Publisher"
end
