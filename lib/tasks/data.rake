desc 'Import school data'
namespace :data do
  namespace :schools do
    task import: :environment do
      puts "Running rake task in environment: #{Rails.env}"
      UpdateSchoolsDataFromSourceJob.new.perform
    end
  end
end
