namespace :vacancies do
  desc "Backfill vacancy religion_type where it's nil to 'no_religion'"
  task backfill_religion_type: :environment do
    puts "Starting backfill of vacancy religion_type..."
    
    vacancies_to_update = Vacancy.where(religion_type: nil)
    total_count = vacancies_to_update.count
    
    puts "Found #{total_count} vacancies with null religion_type"
    
    updated_count = vacancies_to_update.update_all(religion_type: 0) # 0 corresponds to 'no_religion'
    puts "Successfully updated #{updated_count} vacancies to have religion_type: 'no_religion'"
    
    puts "Backfill complete!"
  end
end