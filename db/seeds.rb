raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

Gias::ImportSchoolsAndLocalAuthorities.new.call
Gias::ImportTrusts.new.call

ImportPolygonDataJob.perform_now

bexleyheath_school = School.find_by!(urn: "137138")
weydon_trust = SchoolGroup.find_by!(uid: "16644")
southampton_la = SchoolGroup.find_by!(local_authority_code: "852")

# Users
users = [
  { email: "alex.bowen@digital.education.gov.uk", family_name: "Bowen", given_name: "Alex" },
  { email: "alex.wiskar@digital.education.gov.uk", family_name: "Wiskar", given_name: "Alex" },
  { email: "ben.mitchell@digital.education.gov.uk", family_name: "Mitchell", given_name: "Ben" },
  { email: "cesidio.dilanda@digital.education.gov.uk", family_name: "Di Landa", given_name: "Cesidio" },
  { email: "christian.sutter@digital.education.gov.uk", family_name: "Sutter", given_name: "Christian" },
  { email: "colin.saliceti@digital.education.gov.uk", family_name: "Saliceti", given_name: "Colin" },
  { email: "danny.chadburn@digital.education.gov.uk", family_name: "Chadburn", given_name: "Danny" },
  { email: "ife.akinbolaji@digital.education.gov.uk", family_name: "Akinbolaji", given_name: "Ife" },
  { email: "joseph.hull@digital.education.gov.uk", family_name: "Hull", given_name: "Joseph" },
  { email: "leonie.shanks@digital.education.gov.uk", family_name: "Shanks", given_name: "Leonie" },
  { email: "molly.capstick@digital.education.gov.uk", family_name: "Capstick", given_name: "Molly" },
  { email: "rachael.harvey@digital.education.gov.uk", family_name: "Harvey", given_name: "Rachael" },
  { email: "rishil.patel@digital.education.gov.uk", family_name: "Patel", given_name: "Rishil" },
  { email: "rob.young@digital.education.gov.uk", family_name: "Young", given_name: "Rob" },
  { email: "rose.mackworth-young@digital.education.gov.uk", family_name: "Mackworth-Young", given_name: "Rose" },
  { email: "sabrina.altieri@education.gov.uk", family_name: "Altieri", given_name: "Sabrina" },
  { email: "shahad.rahman@digital.education.gov.uk", family_name: "Rahman", given_name: "Shahad" },
]

users.each do |user|
  Publisher.create(organisations: [bexleyheath_school, weydon_trust, southampton_la], **user)
  SupportUser.create(user)
end

# Vacancies at Bexleyheath school
attrs = { organisations: [bexleyheath_school], publisher_organisation: bexleyheath_school, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# Vacancies at a school that belongs to Weydon Multi Academy Trust
attrs = { organisations: [weydon_trust.schools.first], publisher_organisation: weydon_trust.schools.first, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# Vacancies at a school that belongs to Southampton local authority
attrs = { organisations: [southampton_la.schools.first], publisher_organisation: southampton_la.schools.first, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# Vacancies at Weydon trust central office
attrs = { organisations: [weydon_trust], publisher_organisation: weydon_trust, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, :central_office, **attrs) }

# Vacancies at multiple schools in Weydon trust
attrs = { organisations: weydon_trust.schools, publisher_organisation: weydon_trust, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, :at_multiple_schools, **attrs) }

# Vacancies at multiple schools in Southampton local authority
attrs = { organisations: southampton_la.schools.first(5), publisher_organisation: southampton_la, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :published, :at_multiple_schools, **attrs) }

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
