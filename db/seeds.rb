raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

Gias::ImportSchoolsAndLocalAuthorities.new.call
Gias::ImportTrusts.new.call

single_school_one = School.find_by(urn: "137138")

local_authority_one = SchoolGroup.find_by(local_authority_code: "852")
la_school_one = local_authority_one.schools.first
la_school_two = local_authority_one.schools.second

trust_one = SchoolGroup.find_by(uid: "16644")
trust_school_one = trust_one.schools.first
trust_school_two = trust_one.schools.second
trust_school_three = trust_one.schools.third
trust_school_four = trust_one.schools.fourth
trust_school_five = trust_one.schools.fifth
trust_school_six = trust_one.schools[5]
trust_school_seven = trust_one.schools[6]

organisations = [single_school_one, trust_one, local_authority_one]

Publisher.create(oid: "899808DB-9038-4779-A20A-9E47B9DB99F9", organisations: organisations, email: "alex.bowen@digital.education.gov.uk", family_name: "Bowen", given_name: "Alex")
Publisher.create(oid: "D9F2B98E-F226-4C82-843B-185DE1311878", organisations: organisations, email: "alex.wiskar@digital.education.gov.uk", family_name: "Wiskar", given_name: "Alex")
Publisher.create(oid: "B553A9A4-869B-44FA-8146-D35657EAD590", organisations: organisations, email: "ben.mitchell@digital.education.gov.uk", family_name: "Mitchell", given_name: "Ben")
Publisher.create(oid: "ED61B414-EFE4-4B32-82BC-FC9751F8443B", organisations: organisations, email: "cesidio.dilanda@digital.education.gov.uk", family_name: "Di Landa", given_name: "Cesidio")
Publisher.create(oid: "5A21B414-EFE4-4B32-82BC-FC9751F841A5", organisations: organisations, email: "christian.sutter@digital.education.gov.uk", family_name: "Sutter", given_name: "Christian")
Publisher.create(oid: "421542E6-ED96-4656-B61F-A06D8D487C07", organisations: organisations, email: "colin.saliceti@digital.education.gov.uk", family_name: "Saliceti", given_name: "Colin")
Publisher.create(oid: "C20E1526-FEB0-4A7C-9651-2ADF03FC57BF", organisations: organisations, email: "danny.chadburn@digital.education.gov.uk", family_name: "Chadburn", given_name: "Danny")
Publisher.create(oid: "B81FC38C-4122-4BCE-9F1D-8B1A328FA4D8", organisations: organisations, email: "david.mears@digital.education.gov.uk", family_name: "Mears", given_name: "David")
Publisher.create(oid: "C20E1526-FEB0-4A7C-9651-2ADF03FC57EE", organisations: organisations, email: "ife.akinbolaji@digital.education.gov.uk", family_name: "Akinbolaji", given_name: "Ife")
Publisher.create(oid: "A111A1AA-A111-1111-1AA1-AAAA1A111A1B", organisations: organisations, email: "jesse.yuen@digital.education.gov.uk", family_name: "Yuen", given_name: "Jesse")
Publisher.create(oid: "DF97F25C-3A3E-4655-B7D3-5CDBDCBBBC69", organisations: organisations, email: "joseph.hull@digital.education.gov.uk", family_name: "Hull", given_name: "Joseph")
Publisher.create(oid: "CA300D6A-4FC1-4C1E-97E5-D6BD4FDB80FF", organisations: organisations, email: "leonie.shanks@digital.education.gov.uk", family_name: "Shanks", given_name: "Leonie")
Publisher.create(oid: "EC3312BA-E33B-4791-A815-4D1907DD578E", organisations: organisations, email: "mili.malde@digital.education.gov.uk", family_name: "Malde", given_name: "Mili")
Publisher.create(oid: "EB38B29A-3BA8-45D5-9CEC-89CE5C3BC14D", organisations: organisations, email: "molly.capstick@digital.education.gov.uk", family_name: "Capstick", given_name: "Molly")
Publisher.create(oid: "7AEC8E8D-6036-4E6E-92A4-800E381A12E0", organisations: organisations, email: "rose.mackworth-young@digital.education.gov.uk", family_name: "Mackworth-Young", given_name: "Rose")

publishers = Publisher.all

# Vacancies

## Bexleyheath

### Published

7.times do
  FactoryBot.create(:vacancy, :published, :at_one_school,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisations: [single_school_one])
end

2.times do
  FactoryBot.create(:vacancy, :published, :no_tv_applications,
                    :at_one_school, publisher_organisation: single_school_one,
                                    publisher: publishers.sample,
                                    organisations: [single_school_one])
end

### Scheduled

4.times do
  FactoryBot.create(:vacancy, :future_publish, :at_one_school,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisations: [single_school_one])
end

### Draft

4.times do
  FactoryBot.create(:vacancy, :draft, :at_one_school,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisations: [single_school_one])
end

### Expired

4.times do
  expired_vacancy = FactoryBot.build(:vacancy, :expired, :at_one_school,
                                     publisher_organisation: single_school_one,
                                     publisher: publishers.sample,
                                     organisations: [single_school_one])

  expired_vacancy.save(validate: false)
end

## Weydon Multi Academy Trust

weydon_schools = trust_one.schools

#### At one school

#### Published

8.times do
  school = weydon_schools.sample

  FactoryBot.create(:vacancy, :published, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisations: [school])
end

4.times do
  school = weydon_schools.sample

  FactoryBot.create(:vacancy, :published, :no_tv_applications, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisations: [school])
end

#### Scheduled

4.times do
  school = weydon_schools.sample

  FactoryBot.create(:vacancy, :future_publish, :at_one_school,
                    publish_on: Date.current + 6.months,
                    expires_at: 2.years.from_now.change(hour: 9, minute: 0),
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisations: [school])
end

### Draft

4.times do
  school = weydon_schools.sample

  FactoryBot.create(:vacancy, :draft, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisations: [school])
end

### Expired

4.times do
  school = weydon_schools.sample

  expired_vacancy = FactoryBot.build(:vacancy, :expired, :at_one_school,
                                     publisher_organisation: school,
                                     publisher: publishers.sample,
                                     organisations: [school])

  expired_vacancy.save(validate: false)
end

#### At multiple schools

FactoryBot.create(:vacancy, :published, :at_multiple_schools,
                  publisher_organisation: trust_one,
                  publisher: publishers.sample,
                  organisations: [trust_school_one, trust_school_two, trust_school_three, trust_school_four, trust_school_five, trust_school_six, trust_school_seven])

#### At the central office

# Pass in vacancy id used in application_submitted_at_central_office in /spec/mailers/previews/jobseekers/job_application_preview.rb
FactoryBot.create(:vacancy, :central_office,
                  id: "7bfadb84-cf30-4121-88bd-a9f958440cc9",
                  publisher_organisation: trust_one,
                  publisher: publishers.sample,
                  organisations: [trust_one])

## Southampton

la_schools = local_authority_one.schools

### At one school

#### Published

4.times do
  school = la_schools.sample

  FactoryBot.create(:vacancy, :published, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisations: [school])
end

#### Scheduled

4.times do
  school = la_schools.sample

  FactoryBot.create(:vacancy, :future_publish, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisations: [school])
end

#### Draft

4.times do
  school = la_schools.sample

  FactoryBot.create(:vacancy, :draft, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisations: [school])
end

#### Expired

4.times do
  school = la_schools.sample

  expired_vacancy = FactoryBot.build(:vacancy, :expired, :at_one_school,
                                     publisher_organisation: school,
                                     publisher: publishers.sample,
                                     organisations: [school])

  expired_vacancy.save(validate: false)
end

### At multiple schools

# Pass in vacancy id used in application_submitted_at_multiple_schools in /spec/mailers/previews/jobseekers/job_application_preview.rb
FactoryBot.create(:vacancy, :published, :at_multiple_schools,
                  id: "9910d184-5686-4ffc-9322-69aa150c19d3",
                  publisher_organisation: local_authority_one,
                  publisher: publishers.sample,
                  organisations: [la_school_one, la_school_two])

Vacancy.index.clear_index
Vacancy.reindex!

# Jobseekers

## Create the jobseeker account that users are accustomed to logging in with
Jobseeker.create(email: "jobseeker@example.com", password: "password", confirmed_at: Time.zone.now)

# Create extra jobseekers so each vacancy has multiple applications

5.times do |i|
  Jobseeker.create(email: "jobseeker#{i}@example.com",
                   password: "password",
                   confirmed_at: Time.zone.now)
end

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
FactoryBot.create(:job_application, :status_reviewed,
                  jobseeker: jobseeker,
                  vacancy: vacancy)

FactoryBot.create(:job_application, :status_shortlisted,
                  jobseeker: jobseeker,
                  vacancy: vacancy)

FactoryBot.create(:job_application, :status_unsuccessful,
                  jobseeker: jobseeker,
                  vacancy: vacancy)

FactoryBot.create(:job_application, :status_withdrawn,
                  jobseeker: jobseeker,
                  vacancy: vacancy)
