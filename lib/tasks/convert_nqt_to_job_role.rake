namespace :data do
  desc 'Convert NQT field to job role field'
  namespace :convert_nqt do
    task vacancies: :environment do
      updated_count = 0
      should_be_updated_count = Vacancy.where(newly_qualified_teacher: true).count

      Rails.logger.info(
        "Conversion of NQT fields to job role has been started for #{should_be_updated_count} vacancies"
      )
      Rollbar.log(
        :info,
        "Conversion of NQT fields to job role has been started for #{should_be_updated_count} vacancies"
      )

      Vacancy.where(newly_qualified_teacher: true).in_batches(of: 100).each_record do |vacancy|
        # Some vacancies being updated will have been created prior to certain validations
        job_roles = vacancy.job_roles.presence || []
        job_roles.append(I18n.t('jobs.job_role_options.nqt_suitable'))
        # rubocop:disable Rails/SkipsModelValidations
        vacancy.update_columns(job_roles: job_roles)
        # rubocop:enable Rails/SkipsModelValidations
        updated_count += 1
        Rails.logger.info(
          "Updated vacancy: #{vacancy.job_title} with job_roles: #{I18n.t('jobs.job_role_options.nqt_suitable')}"
        )
      end

      Rails.logger.info("Conversion of NQT fields to job role has been completed for #{updated_count} vacancies")
      Rollbar.log(:info, "Conversion of NQT fields to job role has been completed for #{updated_count} vacancies")
    end
  end
end
