namespace :data do
  desc 'Import school data'
  namespace :schools do
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      UpdateSchoolsDataFromSourceJob.perform_later
    end
  end

  desc 'Migrate phase to phases'
  namespace :phase do
    task migrate: :environment do
      Rails.logger.debug("Running phase migration task in #{Rails.env}")

      Subscription.all.each do |subscription|
        search_criteria = subscription.search_criteria_to_h

        next unless search_criteria.key?('phase')
        next if search_criteria.key?('phases')

        search_criteria['phases'] = [search_criteria['phase']]
        search_criteria.delete('phase')

        subscription.update!(search_criteria: search_criteria.to_json)
      end
    end
  end
end
