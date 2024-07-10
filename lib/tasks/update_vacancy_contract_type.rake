namespace :vacancies do
  desc "Update vacancies with contract_type == parental_leave_cover to contract_type == fixed_term and set is_parental_leave_cover to true"
  task update_parental_leave_cover: :environment do
    vacancies_to_update = Vacancy.where(contract_type: Vacancy.contract_types[:parental_leave_cover])
    
    vacancies_to_update.find_each do |vacancy|
      vacancy.update(
        contract_type: Vacancy.contract_types[:fixed_term],
        is_parental_leave_cover: true,
        fixed_term_contract_duration: vacancy.parental_leave_cover_contract_duration
      )
    end

    puts "#{vacancies_to_update.count} vacancies updated successfully."
  end
end
