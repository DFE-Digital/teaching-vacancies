module Jobseekers::JobApplications::SelfDisclosure
  class ConfirmationForm < BaseForm
    attribute :agreed_for_processing, :boolean
    attribute :agreed_for_criminal_record, :boolean
    attribute :agreed_for_organisation_update, :boolean
    attribute :agreed_for_information_sharing, :boolean

    validates :agreed_for_processing, inclusion: { in: [true] }
    validates :agreed_for_criminal_record, inclusion: { in: [true] }
    validates :agreed_for_organisation_update, inclusion: { in: [true] }
    validates :agreed_for_information_sharing, inclusion: { in: [true] }
  end
end
