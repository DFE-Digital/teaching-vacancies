require "rails_helper"
require "rake"

RSpec.describe "vacancy:update_job_roles" do
  let!(:vacancy_with_other_teaching_support_role) { create(:vacancy) }
  let!(:vacancy_with_other_teaching_support_role_and_others) { create(:vacancy) }
  let!(:vacancy) { create(:vacancy, job_roles: %w[it_support other_support]) }

  before do
    # Use `update_column` to manually insert the now-invalid job role `10` into the database.
    # This bypasses enum validation, which would otherwise raise an ArgumentError because `10`has been removed from the JOB_ROLES mapping and is no longer a valid value.
    vacancy_with_other_teaching_support_role.update_column(:job_roles, [10])
    vacancy_with_other_teaching_support_role_and_others.update_column(:job_roles, [0, 1, 10])
  end

  it "updates job_roles from 10 to 16" do
    vacancy_with_other_teaching_support_role.reload
    # ensure update_column worked successfully
    expect(vacancy_with_other_teaching_support_role[:job_roles]).to eq([10])
    expect(vacancy_with_other_teaching_support_role.job_roles).to eq([nil]) # because 10 is invalid

    task.reenable
    task.invoke

    vacancy_with_other_teaching_support_role.reload
    expect(vacancy_with_other_teaching_support_role[:job_roles]).to eq([16])
    expect(vacancy_with_other_teaching_support_role.job_roles).to eq(%w[other_support])
    vacancy_with_other_teaching_support_role_and_others.reload
    expect(vacancy_with_other_teaching_support_role_and_others[:job_roles]).to eq([0, 1, 16])
    expect(vacancy_with_other_teaching_support_role_and_others.job_roles).to eq(%w[teacher headteacher other_support])
    vacancy.reload
    expect(vacancy[:job_roles]).to eq([13, 16])
    expect(vacancy.job_roles).to eq(%w[it_support other_support])
  end
end
