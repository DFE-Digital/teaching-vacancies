require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe ConductForm, type: :model do
    before { allow(Shoulda::Matchers).to receive(:warn) }

    %i[
      is_known_to_children_services
      has_been_dismissed
      has_been_disciplined
      has_been_disciplined_by_regulatory_body
    ].each do |field|
      it { is_expected.to validate_inclusion_of(field).in_array([true, false]) }
    end
  end
end
