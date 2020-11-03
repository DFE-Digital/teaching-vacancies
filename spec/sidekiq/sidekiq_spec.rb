require "rails_helper"

RSpec.describe "Sidekiq configuration" do
  let(:queue_names) do
    # The excluded jobs are not to be run directly.
    # They are either inherited or used by other jobs.
    files_to_exclude = [".", "..", "application_job.rb", "alert_mailer_job.rb", "performance_platform_transactions_queue_job.rb"]
    job_filenames = Dir.entries("./app/jobs/").reject { |filename| files_to_exclude.include?(filename) }
    job_classes = job_filenames.map { |filename| filename.gsub(".rb", "").camelize.constantize }
    job_classes.reject { |job_class| job_class.class == Module }.map(&:queue_name)
  end

  let(:sidekiq_config) { YAML.load_file("./config/sidekiq.yml") }
  let(:sidekiq_schedule) { YAML.load_file("./config/schedule.yml") }
  let(:unscheduled_jobs) do
    %w[
      audit_express_interest_event
      audit_published_vacancy
      audit_search_event
      audit_subscription_creation
      google_indexing
      seed_vacancies_from_api
      vacancy_statistics
    ]
  end

  it "includes all jobs under :queues:" do
    queue_names.each do |queue_name|
      expect(sidekiq_config[:queues].map(&:first)).to include(queue_name)
    end
  end

  it "includes all scheduled jobs in the schedule" do
    # Exclude jobs which are not to be scheduled (which are called elsewhere in codebase)
    (queue_names - unscheduled_jobs).each do |queue_name|
      expect(sidekiq_schedule.keys).to include(queue_name)
      expect(sidekiq_schedule.values.map { |value| value["queue"] }).to include(queue_name)
    end
  end
end
