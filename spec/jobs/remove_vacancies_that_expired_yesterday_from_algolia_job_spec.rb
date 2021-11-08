require "rails_helper"

RSpec.describe RemoveVacanciesThatExpiredYesterdayFromAlgoliaJob do
  subject(:job) { described_class.perform_later }

  it "invokes Vacancy#remove_vacancies_that_expired_yesterday!" do
    expect(Vacancy).to receive(:remove_vacancies_that_expired_yesterday!)
    perform_enqueued_jobs { job }
  end
end
