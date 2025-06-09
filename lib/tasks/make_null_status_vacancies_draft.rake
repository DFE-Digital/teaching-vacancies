namespace :vacancy do
  desc "Convert vacancies with null statuses to drafts"
  task update_null_statuses: :environment do
    Vacancy.where(status: nil).find_each do |v|
      # use this rather than update_column so that type gets set automatically
      v.assign_attributes(status: :draft)
      v.save!(validate: false, touch: false)
    end
  end
end
