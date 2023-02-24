require "rails_helper"

RSpec.describe Jobseekers::Qualifications::CategoryForm, type: :model do
  it { is_expected.to validate_inclusion_of(:category).in_array(Qualification.categories.keys) }
end
