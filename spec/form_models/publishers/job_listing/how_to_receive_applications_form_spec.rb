require "rails_helper"

RSpec.describe Publishers::JobListing::HowToReceiveApplicationsForm, type: :model do
  it { is_expected.to validate_inclusion_of(:receive_applications).in_array(Vacancy.receive_applications.keys) }
end
