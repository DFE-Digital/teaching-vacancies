require "rails_helper"

RSpec.describe DeleteOldVacancyConflictAttemptsJob do
  let!(:recent_conflict) { create(:vacancy_conflict_attempt, created_at: 6.months.ago) }
  let!(:old_conflict) { create(:vacancy_conflict_attempt, created_at: 14.months.ago) }

  before do
    described_class.perform_now
  end

  it "destroys conflict attempts older than 13 months" do
    expect(VacancyConflictAttempt.exists?(old_conflict.id)).to be false
  end

  it "does not destroy recent conflict attempts (less than 13 months old)" do
    expect(VacancyConflictAttempt.exists?(recent_conflict.id)).to be true
  end
end
