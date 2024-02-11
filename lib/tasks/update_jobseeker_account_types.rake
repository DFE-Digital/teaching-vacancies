namespace :jobseeker do
  desc "Update jobseekers with nil account_type to 'teaching'"
  task update_account_types: :environment do
    Jobseeker.where(account_type: nil).update_all(account_type: 'teaching')
  end
end
