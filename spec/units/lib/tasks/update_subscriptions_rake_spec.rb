require 'rails_helper'

RSpec.describe 'subscription_records:convert_subscriptions', type: :task do
  let!(:old_style_subscription) do
    create(:subscription, frequency: :daily,
      search_criteria: { subject: 'english', working_pattern: 'full_time' }.to_json
    )
  end

  let!(:new_style_subscription) do
    create(:subscription, frequency: :daily,
      search_criteria: { subject: 'english', working_patterns: ['full_time', 'part_time'] }.to_json
    )
  end

  let!(:no_working_pattern_subscription) do
    create(:subscription, frequency: :daily, search_criteria: { subject: 'english' }.to_json)
  end

  let!(:nil_criteria_subscription) do
    create(:subscription, frequency: :daily, search_criteria: nil)
  end

  before do
    UpdateSubscriptionsWithNewWorkingPatterns.run!
  end

  it 'Converts a string working pattern to an array working pattern in search criteria' do
    search_criteria_hash = old_style_subscription.reload.search_criteria_to_h
    expect(search_criteria_hash).to eq({ 'subject'=>'english', 'working_patterns'=>['full_time'] })
  end

  it 'Does not make any changes to the search criteria of a new style working pattern subscription' do
    search_criteria_hash = new_style_subscription.reload.search_criteria_to_h
    expect(search_criteria_hash).to eq({ 'subject'=>'english', 'working_patterns'=>['full_time', 'part_time'] })
  end

  it 'Does not make any changes to the search criteria of a subscription with no working pattern' do
    search_criteria_hash = no_working_pattern_subscription.reload.search_criteria_to_h
    expect(search_criteria_hash).to eq({ 'subject'=>'english' })
  end

  it 'Does not make any changes to a subscription with nil search criteria' do
    search_criteria_hash = nil_criteria_subscription.reload.search_criteria_to_h
    expect(search_criteria_hash).to eq({})
  end
end


