require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe BarredListForm, type: :model do
    before { allow(Shoulda::Matchers).to receive(:warn) }

    %i[
      is_barred
      has_been_referred
    ].each do |field|
      it { is_expected.to validate_inclusion_of(field).in_array([true, false]) }
    end
  end
end
