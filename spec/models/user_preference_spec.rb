require 'rails_helper'

RSpec.describe UserPreference, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:school_group).optional }
end
