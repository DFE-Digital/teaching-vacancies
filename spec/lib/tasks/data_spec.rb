require "rails_helper"
require "rake"

RSpec.describe "data.rake" do
  describe ".split_jobseeker_job_preferences_roles" do
    let(:roles_with_senior_leader) { %w[senior_leader teacher sendco] }
    let(:job_preferences) { create(:job_preferences, roles: roles_with_senior_leader) }

    subject(:task) { Rake::Task["db:split_jobseeker_job_preferences_roles"] }

    after { task.reenable }

    it "replaces any appearance of 'senior_leader' role with three different roles" do
      roles = %w[senior_leader teacher sendco]
      job_preferences = create(:job_preferences, roles: roles)

      expect { task.invoke }
        .to change { job_preferences.reload.roles }
        .from(roles)
        .to(%w[teacher sendco headteacher headteacher_deputy headteacher_assistant])
    end

    it "replaces any appearance of 'middle_leader' role with two different roles" do
      roles = %w[teacher middle_leader]
      job_preferences = create(:job_preferences, roles: roles)

      expect { task.invoke }
        .to change { job_preferences.reload.roles }
        .from(roles)
        .to(%w[teacher head_of_year head_of_department])
    end

    it "does not change other roles" do
      roles = %w[teacher sendco]
      job_preferences = create(:job_preferences, roles: roles)
      expect { task.invoke }.not_to(change { job_preferences.reload.roles })
    end
  end
end
