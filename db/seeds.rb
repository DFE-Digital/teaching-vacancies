raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

Gias::ImportSchoolsAndLocalAuthorities.new.call
Gias::ImportTrusts.new.call

bexleyheath_school = School.find_by(urn: "137138")
southampton_local_authority = SchoolGroup.find_by(local_authority_code: "852")
weydon_trust = SchoolGroup.find_by(uid: "16644")

organisations = [bexleyheath_school, weydon_trust, southampton_local_authority]

Publisher.create(organisations: organisations, email: "alex.bowen@digital.education.gov.uk", family_name: "Bowen", given_name: "Alex")
Publisher.create(organisations: organisations, email: "alex.wiskar@digital.education.gov.uk", family_name: "Wiskar", given_name: "Alex")
Publisher.create(organisations: organisations, email: "ben.mitchell@digital.education.gov.uk", family_name: "Mitchell", given_name: "Ben")
Publisher.create(organisations: organisations, email: "cesidio.dilanda@digital.education.gov.uk", family_name: "Di Landa", given_name: "Cesidio")
Publisher.create(organisations: organisations, email: "christian.sutter@digital.education.gov.uk", family_name: "Sutter", given_name: "Christian")
Publisher.create(organisations: organisations, email: "colin.saliceti@digital.education.gov.uk", family_name: "Saliceti", given_name: "Colin")
Publisher.create(organisations: organisations, email: "danny.chadburn@digital.education.gov.uk", family_name: "Chadburn", given_name: "Danny")
Publisher.create(organisations: organisations, email: "david.mears@digital.education.gov.uk", family_name: "Mears", given_name: "David")
Publisher.create(organisations: organisations, email: "ife.akinbolaji@digital.education.gov.uk", family_name: "Akinbolaji", given_name: "Ife")
Publisher.create(organisations: organisations, email: "jesse.yuen@digital.education.gov.uk", family_name: "Yuen", given_name: "Jesse")
Publisher.create(organisations: organisations, email: "joseph.hull@digital.education.gov.uk", family_name: "Hull", given_name: "Joseph")
Publisher.create(organisations: organisations, email: "leonie.shanks@digital.education.gov.uk", family_name: "Shanks", given_name: "Leonie")
Publisher.create(organisations: organisations, email: "mili.malde@digital.education.gov.uk", family_name: "Malde", given_name: "Mili")
Publisher.create(organisations: organisations, email: "molly.capstick@digital.education.gov.uk", family_name: "Capstick", given_name: "Molly")
Publisher.create(organisations: organisations, email: "rose.mackworth-young@digital.education.gov.uk", family_name: "Mackworth-Young", given_name: "Rose")

# Vacancies at Bexleyheath school
attrs = { organisations: [bexleyheath_school], publisher_organisation: bexleyheath_school, publisher: Publisher.all.sample }
7.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
4.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# Vacancies at Weydon Multi Academy Trust
attrs = { organisations: [weydon_trust.schools.first], publisher_organisation: weydon_trust.schools.first, publisher: Publisher.all.sample }
8.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
4.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
4.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# Vacancy at the trust central office
FactoryBot.create(:vacancy, :published, :central_office, organisations: [weydon_trust], publisher_organisation: weydon_trust, publisher: Publisher.all.sample)

# Vacancy at multiple schools in the trust
FactoryBot.create(:vacancy, :published, :at_multiple_schools, organisations: weydon_trust.schools, publisher_organisation: weydon_trust, publisher: Publisher.all.sample)

# Vacancies at Southampton local authority
attrs = { organisations: [southampton_local_authority.schools.first], publisher_organisation: southampton_local_authority.schools.first, publisher: Publisher.all.sample }
7.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
4.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# Vacancies at multiple schools in the local authority
FactoryBot.create(:vacancy, :published, :at_multiple_schools, organisations: southampton_local_authority.schools, publisher_organisation: southampton_local_authority, publisher: Publisher.all.sample)

Vacancy.index.clear_index
Vacancy.reindex!

# Jobseekers
Jobseeker.create(email: "jobseeker@example.com", password: "password", confirmed_at: Time.zone.now)
5.times { |i| Jobseeker.create(email: "jobseeker#{i}@example.com", password: "password", confirmed_at: Time.zone.now) }

# Job Applications

# Drop one vacancy so this can be used later when a specific ID needs to be given to a submitted job application (for mailer previews)
Vacancy.listed.drop(1).each do |vacancy|
  submitted_statuses = %w[submitted reviewed shortlisted unsuccessful withdrawn]
  Jobseeker.where.not(email: "jobseeker@example.com").each do |jobseeker|
    application_status = submitted_statuses.sample
    FactoryBot.create(:job_application, "status_#{application_status}".to_sym, jobseeker: jobseeker, vacancy: vacancy)
    submitted_statuses.delete(application_status)
  end
end

vacancy = Vacancy.listed.where.missing(:job_applications).first
jobseeker = Jobseeker.where.missing(:job_applications).first
FactoryBot.create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy)
FactoryBot.create(:job_application, :status_reviewed, jobseeker: jobseeker, vacancy: vacancy)
FactoryBot.create(:job_application, :status_shortlisted, jobseeker: jobseeker, vacancy: vacancy)
FactoryBot.create(:job_application, :status_unsuccessful, jobseeker: jobseeker, vacancy: vacancy)
FactoryBot.create(:job_application, :status_withdrawn, jobseeker: jobseeker, vacancy: vacancy)
