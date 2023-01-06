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

# Users
users = [
  { email: "alex.lee@digital.education.gov.uk", family_name: "Alex", given_name: "Lee" },
  { email: "alex.bowen@digital.education.gov.uk", family_name: "Bowen", given_name: "Alex" },
  { email: "alisa.ali@digital.education.gov.uk", family_name: "Ali", given_name: "Alisa" },
  { email: "ben.mitchell@digital.education.gov.uk", family_name: "Mitchell", given_name: "Ben" },
  { email: "colin.saliceti@digital.education.gov.uk", family_name: "Saliceti", given_name: "Colin" },
  { email: "davide.dippolito@digital.education.gov.uk", family_name: "Dippolito", given_name: "Davide" },
  { email: "george.schena@digital.education.gov.uk", family_name: "Schena", given_name: "George" },
  { email: "joseph.hull@digital.education.gov.uk", family_name: "Hull", given_name: "Joseph" },
  { email: "leonie.shanks@digital.education.gov.uk", family_name: "Shanks", given_name: "Leonie" },
  { email: "luke.anslow@digital.education.gov.uk", family_name: "Anslow", given_name: "Luke" },
  { email: "rob.young@digital.education.gov.uk", family_name: "Young", given_name: "Rob" },
  { email: "rose.mackworth-young@digital.education.gov.uk", family_name: "Mackworth-Young", given_name: "Rose" },
  { email: "sabrina.altieri@education.gov.uk", family_name: "Altieri", given_name: "Sabrina" },
  { email: "stan.klajn@digital.education.gov.uk", family_name: "Klajn", given_name: "Stan" },
  { email: "stephanie.maskery@digital.education.gov.uk", family_name: "Maskery", given_name: "Stephanie" },
]

users.each do |user|
  Publisher.create(organisations: [bexleyheath_school, weydon_trust, southampton_la], **user)
  SupportUser.create(user)
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
    application_status = statuses.delete(statuses.sample)
    FactoryBot.create(:job_application, :"status_#{application_status}", jobseeker: jobseeker, vacancy: vacancy)
  end
end
