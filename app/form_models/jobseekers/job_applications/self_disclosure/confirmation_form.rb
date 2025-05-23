module Jobseekers::JobApplications::SelfDisclosure
  class ConfirmationForm < BaseForm
    attribute :agreed_for_processing, :boolean
    attribute :agreed_for_criminal_record, :boolean
    attribute :agreed_for_organisation_update, :boolean
    attribute :agreed_for_information_sharing, :boolean

    validates :agreed_for_processing, presence: true
    validates :agreed_for_criminal_record, presence: true
    validates :agreed_for_organisation_update, presence: true
    validates :agreed_for_information_sharing, presence: true
  end
end
