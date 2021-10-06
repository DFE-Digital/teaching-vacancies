raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

single_school_one = FactoryBot.create(:school,
                                      name: "Bexleyheath Academy",
                                      urn: "137138",
                                      phase: :secondary,
                                      url: "http://www.bexleyheathacademy.org/",
                                      minimum_age: 11,
                                      maximum_age: 18,
                                      address: "Woolwich Road",
                                      town: "Bexleyheath",
                                      county: "Kent",
                                      postcode: "DA6 7DA",
                                      region: "London",
                                      geopoint: "POINT(0.146065490118642 51.4578146490981)",
                                      readable_phases: %w[secondary],
                                      detailed_school_type: "Academy sponsor led",
                                      school_type: "Academy",
                                      gias_data: { "ReligiousCharacter (name)": "None" })

local_authority_one = FactoryBot.create(:local_authority,
                                        name: "Southampton",
                                        local_authority_code: "852",
                                        group_type: "local_authority")

la_school_one = FactoryBot.create(:school,
                                  name: "Upton Cross ACE Academy",
                                  urn: "144523",
                                  phase: :primary,
                                  url: "http://www.uptoncross.kernowlearning.co.uk",
                                  minimum_age: 4,
                                  maximum_age: 11,
                                  address: "Upton Cross",
                                  town: "Liskeard",
                                  county: "Cornwall",
                                  postcode: "PL14 5AX",
                                  region: "South West",
                                  geopoint: "POINT(-4.427269703777728 50.52350433336815)",
                                  readable_phases: %w[primary],
                                  detailed_school_type: "Academy converter",
                                  school_type: "Academy",
                                  gias_data: { "ReligiousCharacter (name)": "None" })

# A second school at the local authority to enable seeding a vacancy at multiple schools.
la_school_two = FactoryBot.create(:school,
                                  name: "Heathfield Infant School",
                                  urn: "116097",
                                  phase: :primary,
                                  url: "http://www.townhilljuniorschool.co.uk",
                                  minimum_age: 4,
                                  maximum_age: 7,
                                  address: "Valentine Avenue",
                                  town: "Southampton",
                                  county: "Hampshire",
                                  postcode: "SO19 0EQ",
                                  region: "London",
                                  geopoint: "POINT(-1.3417708429893471 50.89640138403752)",
                                  readable_phases: %w[primary],
                                  detailed_school_type: "Community school",
                                  school_type: "Local authority maintained schools",
                                  gias_data: { "ReligiousCharacter (name)": "None" })

trust_one = FactoryBot.create(:trust,
                              name: "Weydon Multi Academy Trust",
                              uid: "16644",
                              group_type: "Multi-academy trust",
                              address: "Weydon Lane",
                              town: "Farnham",
                              county: "Not recorded",
                              postcode: "GU9 8UG",
                              geopoint: "POINT(-0.814476304733643 51.2023732521965)")

trust_school_one = FactoryBot.create(:school,
                                     name: "Weydon School",
                                     urn: "136531",
                                     phase: :secondary,
                                     url: "http://www.weydonschool.surrey.sch.uk/",
                                     minimum_age: 11,
                                     maximum_age: 16,
                                     address: "Weydon Lane",
                                     town: "Farnham",
                                     county: "Surrey",
                                     postcode: "GU9 8UG",
                                     region: "South East",
                                     geopoint: "POINT(-0.8144622254228397 51.20236411721489)",
                                     readable_phases: %w[secondary],
                                     detailed_school_type: "Academy converter",
                                     school_type: "Academies",
                                     gias_data: { "ReligiousCharacter (name)": "None" })

trust_school_two = FactoryBot.create(:school,
                                     name: "The Park School",
                                     urn: "137524",
                                     phase: :not_applicable,
                                     url: "http://www.thepark.surrey.sch.uk",
                                     minimum_age: 11,
                                     maximum_age: 16,
                                     address: "Onslow Crescent",
                                     town: "Woking",
                                     county: "Surrey",
                                     postcode: "GU22 7AT",
                                     region: "South East",
                                     geopoint: "POINT(-0.5497856835186931 51.31843413306593)",
                                     readable_phases: [],
                                     detailed_school_type: "Academy special sponsor led",
                                     school_type: "Academies",
                                     gias_data: { "ReligiousCharacter (name)": "None" })

trust_school_three = FactoryBot.create(:school,
                                       name: "The Ridgeway School",
                                       urn: "141843",
                                       phase: :not_applicable,
                                       url: nil,
                                       minimum_age: 2,
                                       maximum_age: 19,
                                       address: "14 Frensham Road",
                                       town: "Farnham",
                                       county: "Surrey",
                                       postcode: "GU9 8HB",
                                       region: "South East",
                                       geopoint: "POINT(-0.7936780598044166 51.201836959020504)",
                                       readable_phases: [],
                                       detailed_school_type: "Academy special converter",
                                       school_type: "Academies",
                                       gias_data: { "ReligiousCharacter (name)": "None" })

trust_school_four = FactoryBot.create(:school,
                                      name: "Farnham Heath End",
                                      urn: "144520",
                                      phase: :secondary,
                                      url: "https://www.fhes.org.uk/",
                                      minimum_age: 11,
                                      maximum_age: 16,
                                      address: "Hale Reeds",
                                      town: "Farnham",
                                      county: "Surrey",
                                      postcode: "GU9 9BN",
                                      region: "South East",
                                      geopoint: "POINT(-0.7817786894584878 51.231316451350786)",
                                      readable_phases: %w[secondary],
                                      detailed_school_type: "Academy converter",
                                      school_type: "Academies",
                                      gias_data: { "ReligiousCharacter (name)": "None" })

trust_school_five = FactoryBot.create(:school,
                                      name: "Rodborough",
                                      urn: "137019",
                                      phase: :secondary,
                                      url: "http://www.rodborough.surrey.sch.uk",
                                      minimum_age: 11,
                                      maximum_age: 16,
                                      address: "Rake Lane",
                                      town: "Godalming",
                                      county: "Surrey",
                                      postcode: "GU8 5BZ",
                                      region: "South East",
                                      geopoint: "POINT(-0.6487940940127327 51.16270091037534)",
                                      readable_phases: %w[secondary],
                                      detailed_school_type: "Academy converter",
                                      school_type: "Academies",
                                      gias_data: { "ReligiousCharacter (name)": "None" })

trust_school_six = FactoryBot.create(:school,
                                     name: "The Abbey School",
                                     urn: "146255",
                                     phase: :not_applicable,
                                     url: "http://www.abbey.surrey.sch.uk",
                                     minimum_age: 11,
                                     maximum_age: 16,
                                     address: "Menin Way",
                                     town: "Farnham",
                                     county: "Surrey",
                                     postcode: "GU9 8DY",
                                     region: "South East",
                                     geopoint: "POINT(-0.7846967240986934 51.20916271142808)",
                                     readable_phases: [],
                                     detailed_school_type: "Academy special converter",
                                     school_type: "Academies",
                                     gias_data: { "ReligiousCharacter (name)": "None" })

trust_school_seven = FactoryBot.create(:school,
                                       name: "Woolmer Hill School",
                                       urn: "137314",
                                       phase: :secondary,
                                       url: "http://www.woolmerhill.surrey.sch.uk",
                                       minimum_age: 11,
                                       maximum_age: 16,
                                       address: "Woolmer Hill",
                                       town: "Haslemere",
                                       county: "Surrey",
                                       postcode: "GU27 1QB",
                                       region: "South East",
                                       geopoint: "POINT(-0.7485485972532422 51.09286892095426)",
                                       readable_phases: %w[secondary],
                                       detailed_school_type: "Academy converter",
                                       school_type: "Academies",
                                       gias_data: { "ReligiousCharacter (name)": "None" })

SchoolGroupMembership.create(school_group: local_authority_one, school: la_school_one)
SchoolGroupMembership.create(school_group: local_authority_one, school: la_school_two)
SchoolGroupMembership.create(school_group: trust_one, school: trust_school_one)
SchoolGroupMembership.create(school_group: trust_one, school: trust_school_two)
SchoolGroupMembership.create(school_group: trust_one, school: trust_school_three)
SchoolGroupMembership.create(school_group: trust_one, school: trust_school_four)
SchoolGroupMembership.create(school_group: trust_one, school: trust_school_five)
SchoolGroupMembership.create(school_group: trust_one, school: trust_school_six)
SchoolGroupMembership.create(school_group: trust_one, school: trust_school_seven)

# TODO: Is being associated with the school group enough? Check if publisher users need to be associated with the individual schools.
organisation_publishers_attributes = [
  { organisation: single_school_one },
  { organisation: trust_one },
  { organisation: local_authority_one },
]

Publisher.create(oid: "899808DB-9038-4779-A20A-9E47B9DB99F9",
                 email: "alex.bowen@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Bowen",
                 given_name: "Alex")

Publisher.create(oid: "D9F2B98E-F226-4C82-843B-185DE1311878",
                 email: "alex.wiskar@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Wiskar",
                 given_name: "Alex")

Publisher.create(oid: "B553A9A4-869B-44FA-8146-D35657EAD590",
                 email: "ben.mitchell@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Mitchell",
                 given_name: "Ben")

Publisher.create(oid: "ED61B414-EFE4-4B32-82BC-FC9751F8443B",
                 email: "cesidio.dilanda@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Di Landa",
                 given_name: "Cesidio")

Publisher.create(oid: "5A21B414-EFE4-4B32-82BC-FC9751F841A5",
                 email: "christian.sutter@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Sutter",
                 given_name: "Christian")

Publisher.create(oid: "421542E6-ED96-4656-B61F-A06D8D487C07",
                 email: "colin.saliceti@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Saliceti",
                 given_name: "Colin")

Publisher.create(oid: "B81FC38C-4122-4BCE-9F1D-8B1A328FA4D8",
                 email: "david.mears@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Mears",
                 given_name: "David")

Publisher.create(oid: "A111A1AA-A111-1111-1AA1-AAAA1A111A1B",
                 email: "jesse.yuen@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Yuen",
                 given_name: "Jesse")

Publisher.create(oid: "DF97F25C-3A3E-4655-B7D3-5CDBDCBBBC69",
                 email: "joseph.hull@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Hull",
                 given_name: "Joseph")

Publisher.create(oid: "CA300D6A-4FC1-4C1E-97E5-D6BD4FDB80FF",
                 email: "leonie.shanks@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Shanks",
                 given_name: "Leonie")

Publisher.create(oid: "EC3312BA-E33B-4791-A815-4D1907DD578E",
                 email: "mili.malde@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Malde",
                 given_name: "Mili")

Publisher.create(oid: "EB38B29A-3BA8-45D5-9CEC-89CE5C3BC14D",
                 email: "molly.capstick@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Capstick",
                 given_name: "Molly")

Publisher.create(oid: "7AEC8E8D-6036-4E6E-92A4-800E381A12E0",
                 email: "rose.mackworth-young@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Mackworth-Young",
                 given_name: "Rose")

Publisher.create(oid: "C20E1526-FEB0-4A7C-9651-2ADF03FC57BF",
                 email: "danny.chadburn@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Chadburn",
                 given_name: "Danny")

Publisher.create(oid: "C20E1526-FEB0-4A7C-9651-2ADF03FC57EE",
                 email: "ife.akinbolaji@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Akinbolaji",
                 given_name: "Ife")

publishers = Publisher.all

# Vacancies

## Bexleyheath

### Published

7.times do
  FactoryBot.create(:vacancy, :published, :at_one_school,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: single_school_one }])
end

2.times do
  FactoryBot.create(:vacancy, :published, :no_tv_applications,
                    :at_one_school, publisher_organisation: single_school_one,
                                    publisher: publishers.sample,
                                    organisation_vacancies_attributes: [{ organisation: single_school_one }])
end

### Scheduled

4.times do
  FactoryBot.create(:vacancy, :future_publish, :at_one_school,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: single_school_one }])
end

### Draft

4.times do
  FactoryBot.create(:vacancy, :draft, :at_one_school,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: single_school_one }])
end

### Expired

4.times do
  expired_vacancy = FactoryBot.build(:vacancy, :expired, :at_one_school,
                                     publisher_organisation: single_school_one,
                                     publisher: publishers.sample,
                                     organisation_vacancies_attributes: [{ organisation: single_school_one }])

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
                    organisation_vacancies_attributes: [{ organisation: school }])
end

4.times do
  school = weydon_schools.sample

  FactoryBot.create(:vacancy, :published, :no_tv_applications, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }])
end

#### Scheduled

4.times do
  school = weydon_schools.sample

  FactoryBot.create(:vacancy, :future_publish, :at_one_school,
                    publish_on: Date.current + 6.months,
                    expires_at: 2.years.from_now.change(hour: 9, minute: 0),
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }])
end

### Draft

4.times do
  school = weydon_schools.sample

  FactoryBot.create(:vacancy, :draft, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }])
end

### Expired

4.times do
  school = weydon_schools.sample

  expired_vacancy = FactoryBot.build(:vacancy, :expired, :at_one_school,
                                     publisher_organisation: school,
                                     publisher: publishers.sample,
                                     organisation_vacancies_attributes: [{ organisation: school }])

  expired_vacancy.save(validate: false)
end

#### At multiple schools

FactoryBot.create(:vacancy, :published, :at_multiple_schools,
                  publisher_organisation: trust_one,
                  publisher: publishers.sample,
                  organisation_vacancies_attributes: [
                    { organisation: trust_school_one },
                    { organisation: trust_school_two },
                    { organisation: trust_school_three },
                    { organisation: trust_school_four },
                    { organisation: trust_school_five },
                    { organisation: trust_school_six },
                    { organisation: trust_school_seven },
                  ])

#### At the central office

# Pass in vacancy id used in application_submitted_at_central_office in /spec/mailers/previews/jobseekers/job_application_preview.rb
FactoryBot.create(:vacancy, :central_office,
                  id: "7bfadb84-cf30-4121-88bd-a9f958440cc9",
                  publisher_organisation: trust_one,
                  publisher: publishers.sample,
                  organisation_vacancies_attributes: [{ organisation: trust_one }])

## Southampton

la_schools = local_authority_one.schools

### At one school

#### Published

4.times do
  school = la_schools.sample

  FactoryBot.create(:vacancy, :published, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }])
end

#### Scheduled

4.times do
  school = la_schools.sample

  FactoryBot.create(:vacancy, :future_publish, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }])
end

#### Draft

4.times do
  school = la_schools.sample

  FactoryBot.create(:vacancy, :draft, :at_one_school,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }])
end

#### Expired

4.times do
  school = la_schools.sample

  expired_vacancy = FactoryBot.build(:vacancy, :expired, :at_one_school,
                                     publisher_organisation: school,
                                     publisher: publishers.sample,
                                     organisation_vacancies_attributes: [{ organisation: school }])

  expired_vacancy.save(validate: false)
end

### At multiple schools

# Pass in vacancy id used in application_submitted_at_multiple_schools in /spec/mailers/previews/jobseekers/job_application_preview.rb
FactoryBot.create(:vacancy, :published, :at_multiple_schools,
                  id: "9910d184-5686-4ffc-9322-69aa150c19d3",
                  publisher_organisation: local_authority_one,
                  publisher: publishers.sample,
                  organisation_vacancies_attributes: [
                    { organisation: la_school_one },
                    { organisation: la_school_two },
                  ])

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
