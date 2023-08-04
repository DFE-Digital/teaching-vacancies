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
        .to(%w[teacher sendco headteacher deputy_headteacher assistant_headteacher])
    end

    it "replaces any appearance of 'middle_leader' role with two different roles" do
      roles = %w[teacher middle_leader]
      job_preferences = create(:job_preferences, roles: roles)

      expect { task.invoke }
        .to change { job_preferences.reload.roles }
        .from(roles)
        .to(%w[teacher head_of_year_or_phase head_of_department_or_curriculum])
    end

    it "does not change other roles" do
      roles = %w[teacher sendco]
      job_preferences = create(:job_preferences, roles: roles)
      expect { task.invoke }.not_to(change { job_preferences.reload.roles })
    end
  end

  describe ".set_job_roles_from_job_role" do
    subject(:task) { Rake::Task["db:set_job_roles_from_job_role"] }

    after { task.reenable }

    {
      teacher: %w[teacher],
      senior_leader: %w[headteacher deputy_headteacher assistant_headteacher],
      middle_leader: %w[head_of_year_or_phase head_of_department_or_curriculum],
      teaching_assistant: %w[teaching_assistant],
      higher_level_teaching_assistant: %w[higher_level_teaching_assistant],
      education_support: %w[education_support],
      sendco: %w[sendco],
    }.each do |role, roles|
      it "sets job_roles to '#{roles}' from '#{role}' job_role" do
        vacancy = create(:vacancy, job_role: role)
        expect { task.invoke }.to change { vacancy.reload.job_roles }.from([]).to(roles)
      end
    end

    it "does not set job roles for a vacancy without job role" do
      vacancy = create(:vacancy, job_role: nil)
      expect { task.invoke }.not_to change { vacancy.reload.job_roles }.from([])
    end
  end
end
