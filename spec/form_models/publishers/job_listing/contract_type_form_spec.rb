require "rails_helper"

RSpec.describe Publishers::JobListing::ContractTypeForm, type: :model do
  it { is_expected.to validate_inclusion_of(:contract_type).in_array(Vacancy.contract_types.keys) }
end
