namespace :vacancies do
  desc "Fix MyNewTerm ATS vacancies where expires_at was submitted as local BST time but stored as UTC (2026 BST period)"
  task fix_my_new_term_expires_at: :environment do
    count = FixMyNewTermExpiresAt.call
    puts "Done. Fixed #{count} vacancies."
  end
end
