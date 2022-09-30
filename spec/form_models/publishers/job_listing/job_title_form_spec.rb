require "rails_helper"

RSpec.describe Publishers::JobListing::JobTitleForm, type: :model do
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_length_of(:job_title).is_at_least(4).is_at_most(75) }
end
