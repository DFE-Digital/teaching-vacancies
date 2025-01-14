require "rails_helper"

RSpec.describe DeleteOldAlertRunsJob do
  it "deletes alert runs older than a week" do
    alert_run = create(:alert_run, run_on: 8.days.ago)
    described_class.perform_now
    expect(AlertRun).not_to exist(alert_run.id)
  end

  it "does not delete alert runs from exactly a week ago" do
    alert_run = create(:alert_run, run_on: 7.days.ago)
    described_class.perform_now
    expect(AlertRun).to exist(alert_run.id)
  end

  it "does not delete alert runs newer than a week" do
    alert_run = create(:alert_run, run_on: 6.days.ago)
    described_class.perform_now
    expect(AlertRun).to exist(alert_run.id)
  end
end
