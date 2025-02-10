namespace :employments do
  desc "backfill is_current_role for employments"
  task backill_is_current_role: :environment do
    Employment.find_each do |e|
      e.update!(is_current_role: e.current_role == "yes")
    end
  end
end
