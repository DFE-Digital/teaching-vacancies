require 'rails_helper'

RSpec.describe JobAlertFeedback, type: :model do
  it { is_expected.to belong_to(:subscription) }
  it { is_expected.to respond_to(:recaptcha_score) }

  describe 'validations' do
    it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
    it { is_expected.to validate_inclusion_of(:relevant_to_user).in_array([true, false]) }
    it { is_expected.to validate_presence_of(:search_criteria) }
    it { is_expected.to validate_presence_of(:vacancy_ids) }
  end
end
