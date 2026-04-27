desc "Backfill about you"
task backfill_about_you: :environment do
  JobseekerProfile.find_each.reject { |p| p.about_you_richtext.present? }.each do |p|
    p.assign_attributes(about_you_richtext: p.about_you)
    p.save!(touch: false, validate: false)
  end
end
