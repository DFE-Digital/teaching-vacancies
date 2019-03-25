namespace :data do
  desc 'Import school data'
  namespace :schools do
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      UpdateSchoolsDataFromSourceJob.perform_later
    end
  end

  desc 'Backfill AuditData for past vacancy.publish events'
  namespace :backfill do
    namespace :audit_data do
      task vacancy_publishing: :environment do
        PublicActivity::Activity.where(key: 'vacancy.publish').map do |audit|
          begin
            vacancy = Vacancy.find(audit.trackable_id)
          rescue ActiveRecord::RecordNotFound
            next
          end

          if AuditData.where("data->>'id' = ?", vacancy.id).count.zero?
            row = VacancyPresenter.new(vacancy).to_row
            AuditData.create(category: :vacancies, data: row)
          end
        end
      end
    end
  end

  desc 'Migrate working pattern to many-to-many association'
  namespace :working_pattern do
    task migrate: :environment do
      Vacancy.all.each do |vacancy|
        working_pattern = WorkingPattern.find_by(label: vacancy.working_pattern.humanize, slug: vacancy.working_pattern)
        vacancy.working_patterns << working_pattern if working_pattern.present?
        vacancy.save
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end
  end
end
