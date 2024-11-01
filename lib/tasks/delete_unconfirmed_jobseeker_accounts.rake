namespace :jobseekers do
  desc "Delete all the unconfirmed jobseeker accounts not associated with any GovUK OneLogin account"
  task delete_unconfirmed_accounts: :environment do
    Jobseeker.where(confirmed_at: nil, govuk_one_login_id: nil).destroy_all
  end
end
