require "rails_helper"
require "rake"

RSpec.describe "vacancy:update_job_roles" do
  let!(:vacancy1) { create(:vacancy) }
  let!(:vacancy2) { create(:vacancy) }
  let!(:vacancy3) { create(:vacancy, job_roles: %w[it_support other_support]) }

  before do
    # Use `update_column` to manually insert the now-invalid job role `10` into the database.
    # This bypasses enum validation, which would otherwise raise an ArgumentError because `10`has been removed from the JOB_ROLES mapping and is no longer a valid value.
    vacancy1.update_column(:job_roles, [10])
    vacancy2.update_column(:job_roles, [0, 1, 10])
  end

  it "updates job_roles from 10 to 16" do
    vacancy1.reload
    # ensure update_column worked successfully
    expect(vacancy1[:job_roles]).to eq([10])
    expect(vacancy1.job_roles).to eq([nil]) # because 10 is invalid

    task.reenable
    task.invoke

    vacancy1.reload
    expect(vacancy1[:job_roles]).to eq([16])
    expect(vacancy1.job_roles).to eq(%w[other_support])
    vacancy2.reload
    expect(vacancy2[:job_roles]).to eq([0, 1, 16])
    expect(vacancy2.job_roles).to eq(%w[teacher headteacher other_support])
    vacancy3.reload
    expect(vacancy3[:job_roles]).to eq([13, 16])
    expect(vacancy3.job_roles).to eq(%w[it_support other_support])
  end
end
