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
          vacancy = Vacancy.find(audit.trackable_id)

          if AuditData.where("data->>'id' = ?", vacancy.id).count.zero?
            row = VacancyPresenter.new(vacancy).to_row
            AuditData.create(category: :vacancies, data: row)
          end
        end
      end
    end
  end
end
