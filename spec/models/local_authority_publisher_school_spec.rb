require "rails_helper"

RSpec.describe LocalAuthorityPublisherSchool do
  it { is_expected.to belong_to(:publisher_preference) }
  it { is_expected.to belong_to(:school) }
end
