raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

school_one = FactoryBot.create(:school,
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
                               easting: "549194",
                               northing: "175388",
                               geolocation: "(51.4578146490981,0.146065490118642)",
                               readable_phases: %w[secondary],
                               detailed_school_type: "Academy sponsor led",
                               school_type: "Academy",
                               gias_data: { "ReligiousCharacter (name)": "None" })

school_two = FactoryBot.create(:school,
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
                               region: "London",
                               easting: "228041",
                               northing: "72116",
                               geolocation: "(50.52350433336815,-4.427269703777728)",
                               readable_phases: %w[primary],
                               detailed_school_type: "Academy converter",
                               school_type: "Academy",
                               gias_data: { "ReligiousCharacter (name)": "None" })

# A second school at the local authority to enable seeding a vacancy at multiple schools.
school_three = FactoryBot.create(:school,
                                 name: "Townhill Junior School",
                                 urn: "116134",
                                 phase: :primary,
                                 url: "http://www.townhilljuniorschool.co.uk",
                                 minimum_age: 7,
                                 maximum_age: 11,
                                 address: "Benhams Road",
                                 town: "Southampton",
                                 county: "Hampshire",
                                 postcode: "SO18 2NX",
                                 region: "London",
                                 easting: "445283",
                                 northing: "114779",
                                 geolocation: "(50.9306936449461,-1.3569968052135)",
                                 readable_phases: %w[primary],
                                 detailed_school_type: "Foundation school",
                                 school_type: "Local authority maintained schools",
                                 gias_data: { "ReligiousCharacter (name)": "Does not apply" })

trust_one = FactoryBot.create(:trust,
                              name: "Weydon Multi Academy Trust",
                              uid: "16644",
                              group_type: "Multi-academy trust",
                              address: "Weydon Lane",
                              town: "Farnham",
                              county: "Not recorded",
                              postcode: "GU9 8UG",
                              geolocation: "(51.2023732521965,-0.814476304733643)")

local_authority_one = FactoryBot.create(:local_authority,
                                        name: "Southampton",
                                        local_authority_code: "852",
                                        group_type: "local_authority")

SchoolGroupMembership.create(school_group: trust_one, school: school_one)
SchoolGroupMembership.create(school_group: local_authority_one, school: school_two)
SchoolGroupMembership.create(school_group: local_authority_one, school: school_three)

organisation_publishers_attributes = [
  { organisation: school_one },
  { organisation: school_two },
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

Publisher.create(oid: "A111A1AA-A111-1111-1AA1-AAAA1A111A1A",
                 email: "craig.forrester@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Forrester",
                 given_name: "Craig")

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

Publisher.create(oid: "CA300D6A-4FC1-4C1E-97E5-D6BD4FDB80D9",
                 email: "judith.thrasher@digital.education.gov.uk",
                 organisation_publishers_attributes: organisation_publishers_attributes,
                 family_name: "Thrasher",
                 given_name: "Judith")

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

physics_job = FactoryBot.create(:vacancy,
                                id: "20cc99ff-4fdb-4637-851a-68cf5f8fea9f",
                                job_title: "Physics Teacher",
                                subjects: %w[Physics],
                                working_patterns: %w[full_time],
                                salary: "£35,000",
                                publisher: Publisher.find_by(email: "david.mears@digital.education.gov.uk"),
                                publisher_organisation: school_one,
                                organisation_vacancies_attributes: [{ organisation: school_one }])

FactoryBot.create(:vacancy,
                  id: "67991ea9-431d-4d9d-9c99-a78b80108fe1",
                  job_title: "Maths Teacher",
                  subjects: %w[Maths],
                  working_patterns: %w[part_time],
                  salary: "£35,000",
                  publisher: Publisher.find_by(email: "christian.sutter@digital.education.gov.uk"),
                  publisher_organisation: school_one,
                  organisation_vacancies_attributes: [{ organisation: school_two }])

FactoryBot.create(:vacancy,
                  id: "ba7dfaf8-2b9f-4fbe-9243-c16a299598aa",
                  job_title: "English Teacher",
                  subjects: %w[English],
                  working_patterns: %w[full_time],
                  salary: "£35,000",
                  publisher: Publisher.find_by(email: "mili.malde@digital.education.gov.uk"),
                  publisher_organisation: school_one,
                  organisation_vacancies_attributes: [{ organisation: school_one }])

# vacancy at a trust central office
FactoryBot.create(:vacancy, :central_office,
                  id: "7bfadb84-cf30-4121-88bd-a9f958440cc9",
                  job_title: "Trust Executive Officer",
                  subjects: %w[],
                  working_patterns: %w[full_time],
                  salary: "£35,000",
                  expires_at: Faker::Time.forward(days: 7).change(hour: 9, minute: 0),
                  publisher: Publisher.find_by(email: "alex.bowen@digital.education.gov.uk"),
                  publisher_organisation: trust_one,
                  organisation_vacancies_attributes: [{ organisation: trust_one }])

# vacancy at multiple schools in a local authority
FactoryBot.create(:vacancy, :at_multiple_schools,
                  id: "9910d184-5686-4ffc-9322-69aa150c19d3",
                  job_title: "PE Teacher",
                  subjects: ["Physical Education"],
                  working_patterns: %w[full_time],
                  salary: "£30,000",
                  publisher: Publisher.find_by(email: "cesidio.dilanda@digital.education.gov.uk"),
                  publisher_organisation: school_two,
                  organisation_vacancies_attributes: [{ organisation: school_two }, { organisation: school_three }])

FactoryBot.create(:vacancy,
                  id: "3bf67da6-039c-4ee1-bf59-8475672a0d2b",
                  job_title: "Chemistry Teacher",
                  subjects: %w[Chemistry],
                  working_patterns: %w[full_time part_time job_share],
                  salary: "£55,000",
                  publisher: Publisher.find_by(email: "david.mears@digital.education.gov.uk"),
                  publisher_organisation: school_two,
                  organisation_vacancies_attributes: [{ organisation: school_two }])

FactoryBot.create(:vacancy,
                  id: "e750baf6-cc9a-4b93-84cf-ee4e5f8a7ee4",
                  job_title: "Geography Teacher",
                  subjects: %w[Geography],
                  working_patterns: %w[part_time job_share],
                  salary: "£25,000",
                  publisher: Publisher.find_by(email: "joseph.hull@digital.education.gov.uk"),
                  publisher_organisation: school_one,
                  organisation_vacancies_attributes: [{ organisation: school_one }])

# scheduled vacancy
FactoryBot.create(:vacancy,
                  job_title: "Teacher of Drama",
                  subjects: %w[Drama],
                  salary: "£28,000",
                  publish_on: 1.month.from_now.to_date,
                  expires_at: 2.month.from_now.change(hour: 9, minute: 0),
                  starts_on: 3.month.from_now.to_date,
                  publisher: Publisher.find_by(email: "joseph.hull@digital.education.gov.uk"),
                  publisher_organisation: school_one,
                  organisation_vacancies_attributes: [{ organisation: school_one }])

# expired vacancy
expired_one = FactoryBot.build(:vacancy,
                               job_title: "Subject lead in Art",
                               subjects: %w[Art],
                               working_patterns: %w[full_time part_time job_share],
                               salary: "£32,000",
                               publish_on: 5.days.ago.to_date,
                               expires_at: 2.days.ago.to_date.change(hour: 9, minute: 0),
                               publisher: Publisher.find_by(email: "joseph.hull@digital.education.gov.uk"),
                               publisher_organisation: school_one,
                               organisation_vacancies_attributes: [{ organisation: school_one }])
expired_one.send :set_slug
expired_one.save(validate: false)

expired_two = FactoryBot.build(:vacancy,
                               job_title: "Subject lead in Drama",
                               subjects: %w[Drama],
                               working_patterns: %w[full_time part_time job_share],
                               salary: "£46,000",
                               publish_on: 5.days.ago.to_date,
                               expires_at: 2.days.ago.to_date.change(hour: 9, minute: 0),
                               publisher: Publisher.find_by(email: "joseph.hull@digital.education.gov.uk"),
                               publisher_organisation: school_one,
                               organisation_vacancies_attributes: [{ organisation: school_one }])
expired_two.send :set_slug
expired_two.save(validate: false)

Vacancy.index.clear_index
Vacancy.reindex!

jobseeker = Jobseeker.create(email: "jobseeker@example.com",
                             password: "password",
                             confirmed_at: Time.zone.now)

FactoryBot.create(:job_application, :status_submitted,
                  id: "6683c564-15e6-41af-ab44-7adf125f4c84",
                  jobseeker: jobseeker,
                  vacancy: physics_job)
