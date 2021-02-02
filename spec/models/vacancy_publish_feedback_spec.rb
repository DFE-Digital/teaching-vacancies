require "rails_helper"

RSpec.describe VacancyPublishFeedback, type: :model do
  it { is_expected.to belong_to(:vacancy) }
  it { is_expected.to belong_to(:publisher) }
end
