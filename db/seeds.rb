raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

Gias::ImportSchoolsAndLocalAuthorities.new.call
Gias::ImportTrusts.new.call

ImportPolygonDataJob.perform_now
SetOrganisationSlugsJob.perform_later

bexleyheath_school = School.find_by!(urn: "137138")
weydon_trust = SchoolGroup.find_by!(uid: "16644")
southampton_la = SchoolGroup.find_by!(local_authority_code: "852")
outwood_grange = SchoolGroup.find_by!(uid: "4119")

# Team users
users = [
  { email: "alisa.ali@education.gov.uk", family_name: "Ali", given_name: "Alisa" },
  { email: "brandon1.chan@education.gov.uk", family_name: "Chan", given_name: "Brandon" },
  { email: "chloe.ewens@education.gov.uk", family_name: "Ewens", given_name: "Chloe" },
  { email: "davide.dippolito@education.gov.uk", family_name: "Dippolito", given_name: "Davide" },
  { email: "fisal.yusuf@education.gov.uk", family_name: "Yusuf", given_name: "Fisal" },
  { email: "halima.ikuomola@education.gov.uk", family_name: "Ikuomola", given_name: "Halima" },
  { email: "ellie.nodder@education.gov.uk", family_name: "Nodder", given_name: "Ellie" },
  { email: "joe.gibb@education.gov.uk", family_name: "Gibb", given_name: "Joe" },
  { email: "kyle.macpherson@education.gov.uk", family_name: "MacPherson", given_name: "Kyle" },
  { email: "luke.anslow@education.gov.uk", family_name: "Anslow", given_name: "Luke" },
  { email: "marc.sardon@education.gov.uk", family_name: "Sardon", given_name: "Marc" },
  { email: "stephanie.maskery@education.gov.uk", family_name: "Maskery", given_name: "Stephanie" },
  { email: "stephen.dicks@education.gov.uk", family_name: "Dicks", given_name: "Stephen" },
  { email: "yvonne.ridley@education.gov.uk", family_name: "Yvonne", given_name: "Ridley" },
]

users.each do |user|
  Publisher.create(organisations: [bexleyheath_school, weydon_trust, southampton_la, outwood_grange], **user)
  SupportUser.create(user)
  FactoryBot.create(:jobseeker, email: user[:email], password: "password")
end

# Vacancies at Bexleyheath school
attrs = { organisations: [bexleyheath_school], phases: [bexleyheath_school.readable_phase], publisher_organisation: bexleyheath_school, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :published, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, **attrs) }
2.times { FactoryBot.create(:vacancy, :draft, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, **attrs).save(validate: false) }

# Vacancies at a school that belongs to Outwood Grange
school = outwood_grange.schools.first
attrs = { organisations: [school], phases: ["secondary"], publisher_organisation: school, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :published, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, **attrs) }
2.times { FactoryBot.create(:vacancy, :draft, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, **attrs).save(validate: false) }

# Vacancies at a school that belongs to Southampton local authority
school = southampton_la.schools.first
attrs = { organisations: [school], phases: ["primary"], publisher_organisation: school, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :published, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, **attrs) }
2.times { FactoryBot.create(:vacancy, :draft, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, **attrs).save(validate: false) }

# Vacancies at Outwood Grange central office
attrs = { organisations: [outwood_grange], phases: %w[secondary], publisher_organisation: outwood_grange, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, **attrs) }

# Vacancies at multiple schools in Outwood Grange
attrs = { organisations: outwood_grange.schools, phases: %w[secondary], publisher_organisation: outwood_grange, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, **attrs) }

# Vacancies at multiple schools in Southampton local authority
attrs = { organisations: southampton_la.schools.first(5), phases: %w[primary], publisher_organisation: southampton_la, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, **attrs) }

# Jobseekers
seed_count = ENV.fetch("PROFILE_SEED_COUNT", 300).to_i
Jobseeker.transaction do
  FactoryBot.create(:jobseeker, email: "jobseeker@contoso.com", password: "password")
  (2 * seed_count).times { |i| FactoryBot.create(:jobseeker, email: "jobseeker#{i}@contoso.com", password: "password") }
end

# Job Applications
Vacancy.listed.each do |vacancy|
  statuses = JobApplication.statuses.keys
  Jobseeker.where.not(email: "jobseeker@contoso.com").all.sample(JobApplication.statuses.count) do |jobseeker|
    Jobseeker.transaction do
      # Ensures each one of the statuses gets used. When no unused statuses are left, takes random ones from the list for further new applications.
      application_status = statuses.delete(statuses.sample) || JobApplication.statuses.keys.sample
      FactoryBot.create(:job_application, :"status_#{application_status}", jobseeker: jobseeker, vacancy: vacancy)
    end
  end
end

## Jobseeker Profiles
weydon_trust_schools = weydon_trust.schools.all
outwood_trust_schools = outwood_grange.schools.all
location_preference_names = outwood_trust_schools.map(&:postcode)
location_preferences = (outwood_trust_schools + weydon_trust_schools).map(&:postcode)

Jobseeker.first(seed_count).each do |jobseeker|
  Jobseeker.transaction do
    # FactoryBot.create(:jobseeker_profile, :with_personal_details, :with_qualifications, :with_employment_history, jobseeker: jobseeker) do |jobseeker_profile|
    FactoryBot.create(:jobseeker_profile, :with_personal_details, :with_qualifications, :with_employment_history,
                      job_preferences: FactoryBot.build(:job_preferences,
                                                        locations: FactoryBot.build_list(:job_preferences_location, 1, name: location_preference_names.pop || location_preferences.sample)),
                      jobseeker: jobseeker) do |jobseeker_profile|
      # FactoryBot.create(:job_preferences, jobseeker_profile: jobseeker_profile) do |job_preferences|
      #   FactoryBot.create(:job_preferences_location, job_preferences:, name: location_preference_names.pop)
      # end
      # FactoryBot.create(:job_preferences, jobseeker_profile: jobseeker_profile,
      #                   locations: FactoryBot.build_list(:job_preferences_location, 1, name: location_preference_names.pop))
      # :with_employment_history trait creates a job_application through the factory, which in turn creates a vacancy that has no associated organisation and causes review app to break on the jobs page and causes smoke test failures
      jobseeker_profile.employments.each do |employment|
        vacancy_without_org_id = employment.job_application.vacancy_id
        OrganisationVacancy.create(vacancy_id: vacancy_without_org_id, organisation_id: outwood_trust_schools.sample.id)
        # FactoryBot.create(:organisation_vacancy, vacancy_id: vacancy_without_org_id.id, organisation_id: outwood_trust_schools.sample.id)
      end
      # :with_qualifications trait also creates a job_application through the factory, which in turn creates a vacancy that has no associated organisation and causes review app to break on the jobs page and causes smoke test failures.
      jobseeker_profile.qualifications.each do |qualification|
        vacancy_without_org_id = qualification.job_application.vacancy_id
        OrganisationVacancy.create(vacancy_id: vacancy_without_org_id, organisation_id: outwood_trust_schools.sample.id)
        # FactoryBot.create(:organisation_vacancy, vacancy_id: vacancy_without_org_id.id, organisation_id: outwood_trust_schools.sample.id)
      end
    end
  end
end

# still need to delete jobs without an organisation
Vacancy.includes(:organisations).find_each.reject { |v| v.organisation.present? }.each(&:destroy)
