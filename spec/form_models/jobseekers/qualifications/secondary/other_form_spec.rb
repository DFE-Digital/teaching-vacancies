require "rails_helper"

RSpec.describe Jobseekers::Qualifications::Secondary::OtherForm, type: :model do
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_numericality_of(:year).is_less_than_or_equal_to(Time.current.year) }
end
