desc "Backfill fe role QTS required"
task backfill_fe_role_qts_required: :environment do
  # Backfill live and future vacancies
  PublishedVacancy.applicable.find_each.select(&:for_an_fe_college?).each do |vacancy|
    needs_qts_status = vacancy.job_roles.include?("teacher")
    vacancy.assign_attributes(fe_role_qts_required: needs_qts_status)
    vacancy.save!(touch: false, validate: false)
  end
end
