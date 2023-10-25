# rubocop:disable Metrics/BlockLength
namespace :subscriptions do
  desc "Update working_patterns and job_roles in search_criteria for all subscriptions"
  task update_legacy_search_criteria: :environment do
    puts "Starting to update working_patterns and job_roles in search_criteria..."

    target_working_patterns = %w[flexible term_time job_share]
    senior_leader_replacements = %w[headteacher deputy_headteacher assistant_headteacher]
    middle_leader_replacements = %w[head_of_year_or_phase head_of_department_or_curriculum]

    Subscription.find_each do |subscription|
      search_criteria = subscription.search_criteria
      updated = false

      if search_criteria["working_patterns"]&.any? { |pattern| target_working_patterns.include?(pattern) }
        search_criteria["working_patterns"] = search_criteria["working_patterns"].map do |pattern|
          target_working_patterns.include?(pattern) ? "part_time" : pattern
        end
        updated = true
      end

      if search_criteria["job_roles"]
        new_roles = []
        search_criteria["job_roles"].each do |role|
          case role
          when "senior_leader"
            new_roles += senior_leader_replacements
          when "middle_leader"
            new_roles += middle_leader_replacements
          else
            new_roles << role
          end
        end
        search_criteria["job_roles"] = new_roles.uniq
        updated = true
      end

      if updated
        subscription.update(search_criteria: search_criteria)
        puts "Updated Subscription ID: #{subscription.id}"
      end
    end

    puts "Finished updating working_patterns and job_roles in search_criteria."
  end
end
# rubocop:enable Metrics/BlockLength
