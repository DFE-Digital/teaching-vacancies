namespace :employments do
  desc "backfill is_current_role for employments"
  task backfill_is_current_role: :environment do
    # we only need to update the 'current' jobs (71k) as the default on the migration was 'false'
    Employment.job.where(current_role: "yes").find_in_batches do |batch|
      Employment.transaction do
        batch.each do |e|
          e.update!(is_current_role: e.current_role == "yes")
        end
      end
    end
  end
end
