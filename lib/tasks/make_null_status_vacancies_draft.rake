namespace :vacancy do
  desc "Update qualified_teacher_status from 'non_teacher' to 'no'"
  task update_null_statuses: :environment do
    Vacancy.where(status: nil).find_each do |v|
      # use this rather than update_column so that type gets set automatically
      v.update_attributes(status: :draft)
      v.save!(validate: false, touch: false)
    end
  end
end
