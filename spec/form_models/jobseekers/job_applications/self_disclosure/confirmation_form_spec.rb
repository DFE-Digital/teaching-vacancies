require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe ConfirmationForm, type: :model do
    %i[
      agreed_for_processing
      agreed_for_criminal_record
      agreed_for_organisation_update
      agreed_for_information_sharing
    ].each do |field|
      it { is_expected.to validate_inclusion_of(field).in_array([true]) }
    end
  end
end
