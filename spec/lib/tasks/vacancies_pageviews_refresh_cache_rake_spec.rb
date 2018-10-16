require 'rails_helper'
RSpec.describe 'rake vacancies:pageviews:refresh_cache', type: :task do
  it 'Queues jobs to update google analytic information on active and not expired vacancies' do
    active_vacancies = create_list(:vacancy, 10, :published)
    draft_vacancies = create_list(:vacancy, 5, :draft)
    expired_vacancies = build_list(:vacancy, 5, :expired).each { |v| v.save(validate: false) }

    active_vacancies.each do |vacancy|
      expect(CacheWeeklyAnalyticsPageviewsQueueJob).to receive(:perform_later).with(vacancy.id)
      expect(CacheTotalAnalyticsPageviewsQueueJob).to receive(:perform_later).with(vacancy.id)
    end

    draft_vacancies.each do |vacancy|
      expect(CacheWeeklyAnalyticsPageviewsQueueJob).to_not receive(:perform_later).with(vacancy.id)
      expect(CacheTotalAnalyticsPageviewsQueueJob).to_not receive(:perform_later).with(vacancy.id)
    end

    expired_vacancies.each do |vacancy|
      expect(CacheWeeklyAnalyticsPageviewsQueueJob).to_not receive(:perform_later).with(vacancy.id)
      expect(CacheTotalAnalyticsPageviewsQueueJob).to_not receive(:perform_later).with(vacancy.id)
    end

    task.invoke
  end
end
