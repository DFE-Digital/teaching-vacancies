class MigratePersonalStatementJob < ApplicationJob
  def perform(job_application_ids)
    JobApplication.where(id: job_application_ids).find_each do |job_application|
      next if job_application.personal_statement_richtext.present? || job_application.personal_statement.blank?

      job_application.update!(personal_statement_richtext: job_application.personal_statement)
    rescue StandardError => e
      Rails.logger.error "Error migrating JobApplication #{job_application.id}: #{e.message}"
    end
  end
end
