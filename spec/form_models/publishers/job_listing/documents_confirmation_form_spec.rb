require "rails_helper"

RSpec.describe Publishers::JobListing::DocumentsConfirmationForm, type: :model do
  it { is_expected.to validate_inclusion_of(:upload_additional_document).in_array([true, false, "true", "false"]) }
end
