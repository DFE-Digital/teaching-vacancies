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

# Vacancies at a single school
attrs = { publisher: Publisher.all.sample, publisher_organisation: bexleyheath_school, organisations: [bexleyheath_school] }
7.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
4.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# Vacancies at Weydon Multi Academy Trust
attrs = { publisher: Publisher.all.sample, publisher_organisation: weydon_trust.schools.first, organisations: [weydon_trust.schools.first] }
8.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
4.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
4.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# At multiple schools
FactoryBot.create(:vacancy, :published, :at_multiple_schools, publisher_organisation: weydon_trust, publisher: Publisher.all.sample, organisations: weydon_trust.schools)

# At the central office (Pass in vacancy id used in application_submitted_at_central_office in /spec/mailers/previews/jobseekers/job_application_preview.rb)
FactoryBot.create(:vacancy, :published,
                            :central_office,
                            id: "7bfadb84-cf30-4121-88bd-a9f958440cc9",
                            publisher_organisation: weydon_trust,
                            publisher: Publisher.all.sample,
                            organisations: [weydon_trust])

# Vacancies at Southampton local authority
attrs = { publisher: Publisher.all.sample, publisher_organisation: southampton_local_authority.schools.first, organisations: [southampton_local_authority.schools.first] }
7.times { FactoryBot.create(:vacancy, :published, :at_one_school, **attrs) }
2.times { FactoryBot.create(:vacancy, :published, :at_one_school, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :future_publish, :at_one_school, **attrs) }
4.times { FactoryBot.create(:vacancy, :draft, :at_one_school, **attrs) }
4.times { FactoryBot.build(:vacancy, :expired, :at_one_school, **attrs).save(validate: false) }

# At multiple schools (Pass in vacancy id used in application_submitted_at_multiple_schools in /spec/mailers/previews/jobseekers/job_application_preview.rb)
FactoryBot.create(:vacancy, :published,
                            :at_multiple_schools,
                            id: "9910d184-5686-4ffc-9322-69aa150c19d3",
                            publisher_organisation: southampton_local_authority,
                            publisher: Publisher.all.sample,
                            organisations: southampton_local_authority.schools)

Vacancy.index.clear_index
Vacancy.reindex!

# Jobseekers

## Create the jobseeker account that users are accustomed to logging in with
Jobseeker.create(email: "jobseeker@example.com", password: "password", confirmed_at: Time.zone.now)

# Create extra jobseekers so each vacancy has multiple applications
5.times { |i| Jobseeker.create(email: "jobseeker#{i}@example.com", password: "password", confirmed_at: Time.zone.now) }

# Job Applications

# Drop one vacancy so this can be used later when a specific ID needs to be given to a submitted job application (for mailer previews)
Vacancy.listed.drop(1).each do |vacancy|
  submitted_statuses = %w[submitted reviewed shortlisted unsuccessful withdrawn]
  Jobseeker.where.not(email: "jobseeker@example.com").each do |jobseeker|
    application_status = submitted_statuses.sample
    FactoryBot.create(:job_application, "status_#{application_status}".to_sym,
                      jobseeker: jobseeker,
                      vacancy: vacancy)

    submitted_statuses.delete(application_status)
  end
end

vacancy = Vacancy.listed.where.missing(:job_applications).first

jobseeker = Jobseeker.where.missing(:job_applications).first

# Pass in job application id used in application_shortlisted and application_unsuccessful in /spec/mailers/previews/jobseekers/job_application_preview.rb
FactoryBot.create(:job_application, :status_submitted,
                  id: "6683c564-15e6-41af-ab44-7adf125f4c84",
                  jobseeker: jobseeker,
                  vacancy: vacancy)

# Create applications in other states so vacancy has an application in each state
FactoryBot.create(:job_application, :status_reviewed, jobseeker: jobseeker, vacancy: vacancy)
FactoryBot.create(:job_application, :status_shortlisted, jobseeker: jobseeker, vacancy: vacancy)
FactoryBot.create(:job_application, :status_unsuccessful, jobseeker: jobseeker, vacancy: vacancy)
FactoryBot.create(:job_application, :status_withdrawn, jobseeker: jobseeker, vacancy: vacancy)
