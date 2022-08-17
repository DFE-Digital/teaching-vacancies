require "rails_helper"

RSpec.describe Publishers::JobListing::IncludeAdditionalDocumentsForm, type: :model do
  it { is_expected.to validate_inclusion_of(:include_additional_documents).in_array([true, false, "true", "false"]) }
end
