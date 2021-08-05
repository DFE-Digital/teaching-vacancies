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
                                      easting: "549194",
                                      northing: "175388",
                                      geolocation: "(51.4578146490981,0.146065490118642)",
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
                                  easting: "228041",
                                  northing: "72116",
                                  geolocation: "(50.52350433336815,-4.427269703777728)",
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
                                  easting: "446387",
                                  northing: "110975",
                                  geolocation: "(50.89640138403752,-1.3417708429893471)",
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
                              geolocation: "(51.2023732521965,-0.814476304733643)")

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
                                     easting: "482923",
                                     northing: "145462",
                                     geolocation: "(51.20236411721489,0.8144622254228397)",
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
                                     easting: "501159",
                                     northing: "158701",
                                     geolocation: "(51.31843413306593,0.5497856835186931)",
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
                                       easting: "484376",
                                       northing: "145427",
                                       geolocation: "(51.201836959020504,0.7936780598044166)",
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
                                      easting: "485153",
                                      northing: "148719",
                                      geolocation: "(51.231316451350786,0.7817786894584878)",
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
                                      easting: "494578",
                                      northing: "141251",
                                      geolocation: "(51.16270091037534,0.6487940940127327)",
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
                                     easting: "484990",
                                     northing: "146252",
                                     geolocation: "(51.20916271142808,0.7846967240986934)",
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
                                       easting: "487735",
                                       northing: "133362",
                                       geolocation: "(51.09286892095426,0.7485485972532422)",
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

publishers = Publisher.all

# Vacancies

job_titles = ["Teacher of Science  (opportunity exists for the right candidate for Head of Physics and/or KS4 Lead)",
              "PROGRESS LEADER (HEAD OF DEPARTMENT) FOR RS, PSHE, RSE AND CITIZENSHIP EDUCATION  WITH TLR 2.3 £6698",
              "Teacher of Music (Part-time, permanent) to include Music Performance Enhancement project  for 1 year",
              "Teacher of Maths MPS (A recruitment and retention point will be offered to the successful candidate)",
              "Primary teacher for children with Social, Emotional and Mental Health (SEMH) needs (1 year contract)",
              "Teacher of MFL (Spanish with the ability to teach French or German at Key Stage 3) (Maternity Cover)",
              "Head Teacher St Martin & St Mary Primary School Windermere Cumbria (the Lake District National Park)",
              "Full or Part Time Teacher/Tutor of English and/or Maths and/or Science for 1:1  small group tuition ",
              "Teacher of Art within ADT Dept (Secondary) Maternity Cover (1 Yr) with possibility of permanent post",
              "Teacher of Business Studies / Health and Social Care (TLR may be available for a suitable candidate)",
              "Assistant Head Teacher - Pastoral & Well-Being, Designated Safeguarding & Looked After Children Lead",
              "Class Teacher - This role is for a new school, opening on 1st Sept 2021 in Bishop's Stortford North.",
              "We will shortly be recruiting for NQTs and Heads of Departments in various subjects (new school)..  ",
              "Science Teachers (1 year full time contract) (part time considered) starting Summer/Autumn Term 2020",
              "Teacher of Science (Any Science specialism, but with the ability to teach outside of the specialism)",
              "Teacher of Business Studies and Economics (suitable for NQTs). TLR available for experienced teacher",
              "Head of Year (pref. able to teach any of the following subjects: Eng, Media, RS, Maths, S. Sciences)",
              "Cross-Curricular Teacher - East Leeds Educational Centre for Training (ELECT) - Temporary for 1 Year",
              "Teacher with Phase Leader responsibility for pupils with Special Educational Needs (mainly to teach in KS3-KS4)",
              "Teacher of Geography", "Year 4 Class Teacher", "Teacher of Girls' PE", "Head of MFL (French)",
              "Teacher of RE & PSHE", "Teacher of Economics", "KS5 Geography Leader", "KS1/KS2 Phase Leader",
              "Year 6 Class Teacher", "Subject Leader Maths", "Teacher of Chemistry", "Female Teacher of PE",
              "Teacher of Computing", "Assistant Principal ", "Class Teacher (EYFS)", "1:1 English Tutor/s ",
              "Teacher of PE (male)", "Games Design Teacher", "Team Leader of Maths", "KEY STAGE 2 TEACHER ",
              "Mathematics Teacher ", "ICT Network Manager ", "Early Years Educator", "Year 3 Class Teacher",
              "Teacher of Business ", "Teacher of Girl's PE", "Programme Leader MFL", "Year 1 Class Teacher",
              "Teacher of PE (Boys)", "Sikh Studies Teacher", "Teacher of English  ", "Teacher of Religious Education",
              "Teacher of R.E and Citizenship", "Teacher of English (Permanent)", "Creative Industries Technician",
              "Finance and Resource Director ", "Teacher of History (Part-Time)", "Maths Teacher - September 2020",
              "Part-time Teacher of Sociology", "KS2 Part time teacher (Year 5)", "Teacher of Mathematics 0.6 FTE",
              "Teacher of Design & Technology", "Temporary Teacher of Geography", "Lead in Health and Social Care",
              "Director of Learning - Science", "Teacher of Science", "Teacher of English"]

salaries = ["MPR 1 (£24,373 per annum)", "Main pay range 1 to Upper pay range 3, £23,719 to £39,406 per year (full-time equivalent)",
            "£6,084 to £6,084 per year (full-time equivalent)", "Main pay range 2 to Upper pay range 3, £30,113 to £44,541",
            "Main pay range 1 to Upper pay range 3, £30,480 to £49,571", "MPR / UPR  ", "MPS/UPS ",
            "£25,543 to £41,635 per year (full-time equivalent)", "M1-UP3 £25,714 - £41,604 ",
            "£18,795 to £20,344 per year (full-time equivalent)",
            "Main pay range 1 to Main pay range 6, £23,720,.00 to £35,008,.00 per year (full-time equivalent)",
            "MPS / UPS and possibility of TLR ", "£18,795 to £19,171 per year (full-time equivalent)",
            "£46,684 to £54,120", "MPR (UPR for a very strong candidate)",
            "MPS", "Main pay range 1 to Main pay range 6, £24,859 to £34,253",
            "£29,096 to £39,702", "£29,371 - £41,604",
            "Main pay range 1 to Upper pay range 3, £23,720 to £39,406", "Main pay range 1 to Main pay range 6, £23,720 to £35,008",
            "Teachers’ Main / Upper Pay Scale ", "Main pay range 1 to Upper pay range 3, £24,373 to £40,490",
            "£25,079 – £36,227 (FTE)", "Upper pay range 1 to Upper pay range 3, £37,654 to £40,490",
            "MPS/UPS", "tms - ups", "23080-25481",
            "Main/UP Scale [+future possibility of TLR2 award]", "Lead Practitioners range 1 to Lead Practitioners range 5, £41,065 to £45,319",
            "Main pay range 2 to Upper pay range 3, £26,041 to £40,490",
            "Main pay range 1 to Main pay range 6, £24,373 to £35,971 per year (full-time equivalent)",
            "Lead Practitioners range 7 to Lead Practitioners range 11, £47,707 to £52,643",
            "Lead Practitioners range 4 to Lead Practitioners range 4, £46,208 to £46,208", "M1 £25,714 to UPS3 £41,604 ",
            "MPR/UPR", "£16,168 to £17,369", "Main pay range 1 to Main pay range 6, £23,720 to £34,665",
            "Main pay range 1 to Upper pay range 3, £23,719 to £39,406", "MPS/UPS TLR1A (£8,291)",
            "Main pay range 1 to Upper pay range 3, £27,595 to £43,348",
            "Main pay range 1 to Main pay range 6, £25,543 per year (full-time equivalent)",
            "£32,157 - £42,624 per annum", "Main pay range 1 to Upper pay range 3, £23,720 to £39,406 per year (full-time equivalent)",
            "Main / Upper Pay Scale (£25,714 to £41,807)", "Inner London Pay Scales", "L1 - L2  £42,195-£43,251 (dependent on experience)",
            "29,577 - 32,234", "£24,373 to £40,490",
            "Main pay range 1 to Upper pay range 3, £14,232 to £23,643,.60 per year pro rata", "MPR to UPR",
            "MPS/UPS £32,157 - £50,935 per annum", "Up to £40,489 depending on experience.  NQT/MPS/UPS",
            "To be determined depending on qualifications and experience",
            "Teaching Assistant – West Sussex County Council G3 in the range of £18,562 to £18,933 p.a. pro-rata of full time equivalent Midday \"
            Meals Supervisor in the range of grade G2 £18,198 to £18,562 p.a. pro-rata of full time equivalent",
            "Age 18 -20 £14,314 fte (Actual Salary £5,378 pro rata - £7.34 pr hour inc holiday pay Age 21 - 22 £16,508 fte (Actual Salary "\
            "£6,202 pro rata £8.47 pr hour inc holiday pay Age 23+ £18,508 fte (Actual Salary £6,755 pro rata £9.22 pr hour inc holiday pay",
            "M1", "Grade 3 - £18,933 - £20,092 FTE (Actual Salary £15,472 - £16,419)",
            "Main pay range 1 to Upper pay range 3, £24,859 to £40,520 per year (full-time equivalent)",
            "Main pay range 1 to Upper pay range 3, £29,663 to £48,244", "MPR/UPS", "£25,750 to £39,964", "MS/UPS ",
            "Main pay range 4 to Upper pay range 1, £29,194 to £36,646", "Main pay range 1 to Upper pay range 3, £23,716 to £39,404",
            "Main pay range 1 to Upper pay range 3, £28,355 to £44,541"]

## Bexleyheath

### Published

7.times do
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :published,
                    id: SecureRandom.uuid,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: single_school_one }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    job_title: job_title,
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

2.times do
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :published, :no_tv_applications,
                    id: SecureRandom.uuid,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: single_school_one }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    job_title: job_title,
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

### Scheduled

4.times do
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :published,
                    id: SecureRandom.uuid,
                    publish_on: Date.current + 6.months,
                    expires_at: 2.years.from_now.change(hour: 9, minute: 0),
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: single_school_one }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_title: job_title,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

### Draft

4.times do
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :draft,
                    id: SecureRandom.uuid,
                    publisher_organisation: single_school_one,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: single_school_one }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_title: job_title,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

### Expired

4.times do
  job_title = job_titles.sample
  salary = salaries.sample

  expired_vacancy = FactoryBot.build(:vacancy, :expired,
                                     id: SecureRandom.uuid,
                                     publisher_organisation: single_school_one,
                                     publisher: publishers.sample,
                                     organisation_vacancies_attributes: [{ organisation: single_school_one }],
                                     about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                                     benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                                     salary: salary,
                                     job_title: job_title,
                                     job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                                     personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                                     school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  expired_vacancy.save(validate: false)
  job_titles.delete(job_title)
  salaries.delete(salary)
end

## Weydon Multi Academy Trust

weydon_schools = trust_one.schools

#### At one school

#### Published

6.times do
  job_title = job_titles.sample
  school = weydon_schools.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :published,
                    id: SecureRandom.uuid,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_title: job_title,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

4.times do
  school = weydon_schools.sample
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :published, :no_tv_applications,
                    id: SecureRandom.uuid,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_title: job_title,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

#### Scheduled

4.times do
  school = weydon_schools.sample
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :published,
                    id: SecureRandom.uuid,
                    publish_on: Date.current + 6.months,
                    expires_at: 2.years.from_now.change(hour: 9, minute: 0),
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_title: job_title,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

### Draft

4.times do
  school = weydon_schools.sample
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :draft,
                    id: SecureRandom.uuid,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    job_title: job_title,
                    salary: salary,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

### Expired

4.times do
  school = weydon_schools.sample
  job_title = job_titles.sample
  salary = salaries.sample

  expired_vacancy = FactoryBot.build(:vacancy, :expired,
                                     id: SecureRandom.uuid,
                                     publisher_organisation: school,
                                     publisher: publishers.sample,
                                     organisation_vacancies_attributes: [{ organisation: school }],
                                     about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                                     benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                                     salary: salary,
                                     job_title: job_title,
                                     job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                                     personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                                     school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  expired_vacancy.save(validate: false)
  job_titles.delete(job_title)
  salaries.delete(salary)
end

#### At multiple schools

mat_multiple_schools_job_title = job_titles.sample
mat_multiple_schools_salary = salaries.sample

FactoryBot.create(:vacancy, :published, :at_multiple_schools,
                  id: "f96f7efb-4a3f-4076-9eff-d09cbac45da8",
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
                  ],
                  about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                  benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                  salary: mat_multiple_schools_salary,
                  job_title: mat_multiple_schools_job_title,
                  job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                  personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                  school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

job_titles.delete(mat_multiple_schools_job_title)
salaries.delete(mat_multiple_schools_salary)

#### At the central office

mat_central_office_job_title = job_titles.sample
mat_central_office_salary = salaries.sample

FactoryBot.create(:vacancy, :central_office,
                  id: "d8567a2b-f756-479c-a76b-722f29e09134",
                  publisher_organisation: trust_one,
                  publisher: publishers.sample,
                  organisation_vacancies_attributes: [{ organisation: trust_one }],
                  about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                  benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                  salary: mat_central_office_salary,
                  job_title: mat_central_office_job_title,
                  job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                  personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                  school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

job_titles.delete(mat_central_office_job_title)
salaries.delete(mat_central_office_salary)

## Southampton

la_schools = local_authority_one.schools

### At one school

#### Published

4.times do
  school = la_schools.sample
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :published,
                    id: SecureRandom.uuid,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_title: job_title,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

#### Scheduled

4.times do
  school = la_schools.sample
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :published,
                    id: SecureRandom.uuid,
                    publish_on: Date.current + 6.months,
                    expires_at: 2.years.from_now.change(hour: 9, minute: 0),
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_title: job_title,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

#### Draft

4.times do
  school = la_schools.sample
  job_title = job_titles.sample
  salary = salaries.sample

  FactoryBot.create(:vacancy, :draft,
                    id: SecureRandom.uuid,
                    publisher_organisation: school,
                    publisher: publishers.sample,
                    organisation_vacancies_attributes: [{ organisation: school }],
                    about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                    salary: salary,
                    job_title: job_title,
                    job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                    personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                    school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  job_titles.delete(job_title)
  salaries.delete(salary)
end

#### Expired

4.times do
  school = la_schools.sample
  job_title = job_titles.sample
  salary = salaries.sample

  expired_vacancy = FactoryBot.build(:vacancy, :expired,
                                     id: SecureRandom.uuid,
                                     publisher_organisation: school,
                                     publisher: publishers.sample,
                                     organisation_vacancies_attributes: [{ organisation: school }],
                                     about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                                     benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                                     salary: salary,
                                     job_title: job_title,
                                     job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                                     personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                                     school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

  expired_vacancy.save(validate: false)
  job_titles.delete(job_title)
  salaries.delete(salary)
end

### At multiple schools

la_multiple_schools_job_title = job_titles.sample
la_multiple_schools_salary = salaries.sample

FactoryBot.create(:vacancy, :published, :at_multiple_schools,
                  id: "e25a451f-9d73-4259-9142-64864f8c046d",
                  publisher_organisation: local_authority_one,
                  publisher: publishers.sample,
                  organisation_vacancies_attributes: [
                    { organisation: la_school_one },
                    { organisation: la_school_two },
                  ],
                  about_school: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                  benefits: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
                  salary: la_multiple_schools_salary,
                  job_title: la_multiple_schools_job_title,
                  job_advert: Faker::Lorem.paragraph(sentence_count: rand(50..300)),
                  personal_statement_guidance: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                  school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)),
                  readable_job_location: "More than one school (2)")

job_titles.delete(la_multiple_schools_job_title)
salaries.delete(la_multiple_schools_salary)

Vacancy.index.clear_index
Vacancy.reindex!

# Jobseekers

## Create jobseeker account that users are accustomed to logging in with
Jobseeker.create(email: "jobseeker@example.com", password: "password", confirmed_at: Time.zone.now)

# Create extra jobseekers so each vacancy has multiple applications

4.times do |i|
  Jobseeker.create(email: "jobseeker#{i}@example.com",
                   password: "password",
                   confirmed_at: Time.zone.now)
end

# Job Applications
live_vacancy_ids = Vacancy.live.where(enable_job_applications: true).pluck(:id)
throwaway_jobseekers = Jobseeker.where.not(email: "jobseeker@example.com")

throwaway_jobseekers.each do |jobseeker|
  submitted_statuses = %w[submitted reviewed shortlisted unsuccessful withdrawn]

  5.times do
    job_application = FactoryBot.create(:job_application, "status_#{submitted_statuses.sample}".to_sym,
                                        id: SecureRandom.uuid,
                                        jobseeker: jobseeker,
                                        vacancy: Vacancy.find(live_vacancy_ids.sample))

    submitted_statuses.delete(job_application.status)
    live_vacancy_ids.delete(job_application.vacancy.id)
  end
end

# To ensure each published vacancy has at least one unread job application

jobseeker = Jobseeker.find_by(email: "jobseeker@example.com")

Vacancy.published.where(enable_job_applications: true).each do |vacancy|
  FactoryBot.create(:job_application, :status_submitted,
                    id: SecureRandom.uuid,
                    jobseeker: jobseeker,
                    vacancy: vacancy)
end
