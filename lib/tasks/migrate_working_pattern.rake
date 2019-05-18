namespace :data do
  desc 'Migrate vacancy working pattern'
  namespace :working_pattern do
    task migrate: :environment do
      Rails.logger.debug("Running vacancy working pattern migration task in #{Rails.env}")

      Vacancy.where.not(working_pattern: nil)
             .each do |vacancy|
        vacancy.working_patterns = [vacancy.working_pattern]
        vacancy.working_pattern = nil

        vacancy.save!
      end
    end
  end
end
