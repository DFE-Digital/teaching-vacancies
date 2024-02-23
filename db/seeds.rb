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

# Team users
users = [
  { email: "alex.lee@education.gov.uk", family_name: "Alex", given_name: "Lee" },
  { email: "alisa.ali@education.gov.uk", family_name: "Ali", given_name: "Alisa" },
  { email: "brandon1.chan@education.gov.uk", family_name: "Chan", given_name: "Brandon" },
  { email: "colin.saliceti@education.gov.uk", family_name: "Saliceti", given_name: "Colin" },
  { email: "danielle.dean@education.gov.uk", family_name: "Danielle", given_name: "Dean" },
  { email: "davide.dippolito@education.gov.uk", family_name: "Dippolito", given_name: "Davide" },
  { email: "georgina.watts@education.gov.uk", family_name: "Watts", given_name: "Georgina" },
  { email: "luke.anslow@education.gov.uk", family_name: "Anslow", given_name: "Luke" },
  { email: "marc.sardon@education.gov.uk", family_name: "Sardon", given_name: "Marc" },
  { email: "kyle.macpherson@education.gov.uk", family_name: "MacPherson", given_name: "Kyle" },
  { email: "stephanie.maskery@education.gov.uk", family_name: "Maskery", given_name: "Stephanie" },
  { email: "chloe.ewens@education.gov.uk", family_name: "Ewens", given_name: "Chloe" },
  { email: "matthew.jefford@education.gov.uk", family_name: "Jefford", given_name: "Matthew" },
]

users.each do |user|
  Publisher.create(organisations: [bexleyheath_school, weydon_trust, southampton_la], **user)
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

# Vacancies at a school that belongs to Weydon Multi Academy Trust
school = weydon_trust.schools.first
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

# Vacancies at Weydon trust central office
attrs = { organisations: [weydon_trust], phases: %w[secondary], publisher_organisation: weydon_trust, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, **attrs) }

# Vacancies at multiple schools in Weydon trust
attrs = { organisations: weydon_trust.schools, phases: %w[secondary], publisher_organisation: weydon_trust, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, **attrs) }

# Vacancies at multiple schools in Southampton local authority
attrs = { organisations: southampton_la.schools.first(5), phases: %w[primary], publisher_organisation: southampton_la, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, **attrs) }

# Jobseekers
Jobseeker.create(email: "jobseeker@example.com", password: "password", confirmed_at: Time.zone.now)
JobApplication.statuses.count.times { |i| Jobseeker.create(email: "jobseeker#{i}@example.com", password: "password", confirmed_at: Time.zone.now) }

# Job Applications
Vacancy.listed.each do |vacancy|
  statuses = JobApplication.statuses.keys
  Jobseeker.where.not(email: "jobseeker@example.com").each do |jobseeker|
    # Ensures each one of the statuses gets used. When no unused statuses are left, takes random ones from the list for further new applications.
    application_status = statuses.delete(statuses.sample) || JobApplication.statuses.keys.sample
    FactoryBot.create(:job_application, :"status_#{application_status}", jobseeker: jobseeker, vacancy: vacancy)
  end
end

## Jobseeker Profiles
weydon_trust_schools = weydon_trust.schools.all
location_preference_names = weydon_trust_schools.map(&:postcode)

Jobseeker.first(weydon_trust_schools.count).each do |jobseeker|
  FactoryBot.create(:jobseeker_profile, :with_personal_details, :with_qualifications, :with_employment_history, jobseeker: jobseeker) do |jobseeker_profile|
    FactoryBot.create(:job_preferences, jobseeker_profile: jobseeker_profile) do |job_preferences|
      FactoryBot.create(:job_preferences_location, job_preferences:, name: location_preference_names.pop)
    end
    # :with_employment_history trait creates a job_application through the factory, which in turn creates a vacancy that has no associated organisation and causes review app to break on the jobs page and causes smoke test failures
    jobseeker_profile.employments.each do |employment|
      vacancy_without_org_id = employment.job_application.vacancy_id
      OrganisationVacancy.create(vacancy_id: vacancy_without_org_id, organisation_id: weydon_trust_schools.first.id)
    end
    # :with_qualifications trait also creates a job_application through the factory, which in turn creates a vacancy that has no associated organisation and causes review app to break on the jobs page and causes smoke test failures.
    jobseeker_profile.qualifications.each do |qualification|
      vacancy_without_org_id = qualification.job_application.vacancy_id
      OrganisationVacancy.create(vacancy_id: vacancy_without_org_id, organisation_id: weydon_trust_schools.first.id)
    end
  end
end
