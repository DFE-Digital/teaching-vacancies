require 'rails_helper'

RSpec.describe JobAlertFeedback, type: :model do
  it { should belong_to(:subscription) }

  describe 'validations' do
    it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
    it { is_expected.to validate_presence_of(:relevant_to_user) }
    it { is_expected.to validate_presence_of(:search_criteria) }
    it { is_expected.to validate_presence_of(:vacancy_ids) }
  end
end
