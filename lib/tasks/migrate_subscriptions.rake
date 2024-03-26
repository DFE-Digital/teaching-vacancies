# rubocop:disable Metrics/BlockLength

namespace :subscriptions do
  desc "Migrate job_roles to new category fields"
  task migrate_roles: :environment do
    Subscription.find_each(batch_size: 1000) do |subscription|
      search_criteria = subscription.search_criteria

      next unless search_criteria["job_roles"] && search_criteria.values_at("teaching_job_roles", "teaching_support_job_roles", "non_teaching_support_job_roles").none?

      mapped_roles = search_criteria["job_roles"].map { |role|
        if role == "senior_leader"
          Vacancy::SENIOR_LEADER_JOB_ROLES
        elsif role == "middle_leader"
          Vacancy::MIDDLE_LEADER_JOB_ROLES
        else
          role
        end
      }.flatten

      teaching_job_roles = []
      teaching_support_job_roles = []
      non_teaching_support_job_roles = []

      mapped_roles.each do |role|
        if Vacancy::TEACHING_JOB_ROLES.include?(role)
          teaching_job_roles << role
        elsif Vacancy::TEACHING_SUPPORT_JOB_ROLES.include?(role)
          teaching_support_job_roles << role
        elsif Vacancy::NON_TEACHING_SUPPORT_JOB_ROLES.include?(role)
          non_teaching_support_job_roles << role
        end
      end

      search_criteria["teaching_job_roles"] = teaching_job_roles unless teaching_job_roles.empty?
      search_criteria["teaching_support_job_roles"] = teaching_support_job_roles unless teaching_support_job_roles.empty?
      search_criteria["non_teaching_support_job_roles"] = non_teaching_support_job_roles unless non_teaching_support_job_roles.empty?

      search_criteria.delete("job_roles")

      subscription.update_columns(search_criteria: search_criteria)
    end

    puts "Migrated job_roles to new role fields in subscriptions"
  end
end
# rubocop:enable Metrics/BlockLength
