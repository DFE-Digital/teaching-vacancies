require "rails_helper"

RSpec.describe PublisherPreference, type: :model do
  it { should belong_to(:publisher) }
  it { should belong_to(:school_group).optional }
end
