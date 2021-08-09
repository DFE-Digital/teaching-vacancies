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

job_titles = ["Teacher of Music (Part-time, permanent) to include Music Performance Enhancement project  for 1 year",
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
              "Teacher of Maths MPS (A recruitment and retention point will be offered to the successful candidate)",
              "Teacher of Art within ADT Dept (Secondary) Maternity Cover (1 Yr) with possibility of permanent post",
              "Teacher of Business Studies and Economics (suitable for NQTs). TLR available for experienced teacher",
              "Head of Year (pref. able to teach any of the following subjects: Eng, Media, RS, Maths, S. Sciences)",
              "Cross-Curricular Teacher - East Leeds Educational Centre for Training (ELECT) - Temporary for 1 Year",
              "Teacher of Science (Any Science specialism, but with the ability to teach outside of the specialism)",
              "Teacher with Phase Leader responsibility for pupils with Special Educational Needs (mainly to teach in KS3-KS4)",
              "Teacher of Geography", "Teacher of Geography", "Year 4 Class Teacher", "Teacher of Girls' PE",
              "Head of MFL (French)", "Teacher of Girls' PE", "Teacher of RE & PSHE", "Teacher of Economics",
              "Teacher of Geography", "Teacher of Geography", "KS5 Geography Leader", "Teacher of IT",
              "Teacher of Geography", "KS1/KS2 Phase Leader", "Year 6 Class Teacher", "Subject Leader Maths",
              "Teacher of Chemistry", "Teacher of Religious Education", "Teacher of R.E and Citizenship",
              "Teacher of English (Permanent)", "Creative Industries Technician", "Finance and Resource Director ",
              "Teacher of History (Part-Time)", "Maths Teacher - September 2020", "Part-time Teacher of Sociology",
              "Teacher of Religious Education", "KS2 Part time teacher (Year 5)", "Teacher of Religious Education",
              "Teacher of Mathematics 0.6 FTE", "Teacher of Design & Technology", "Temporary Teacher of Geography",
              "Lead in Health and Social Care", "Teacher of Design & Technology", "Director of Learning - Science",
              "Teacher of Art 0.8 fte", "Teacher of Mathematics", "Associate Head Teacher", "Year 3/4 Class Teacher",
              "Teacher of Mathematics", "Teacher of Mathematics", "Teacher of Engineering", "Teacher of Citizenship",
              "SEN Teaching Assistant", "Teacher of Mathematics", "Graphic Design Teacher", "Head of Product Design",
              "Assistant Head Teacher", "Assistant Head Teacher", "Teacher of Mathematics", "PE Teacher - Mainscale",
              "Teacher of Mathematics", "Class Teacher - Year 3", "School Welfare Officer", "Teacher of Mathematics",
              "Maths Teacher (Oxford)"]

salaries = ["Age 18 -20 £14,314 fte (Actual Salary £5,378 pro rata - £7.34 pr hour inc holiday pay Age 21 - 22 £16,508 fte (Actual "\
            "Salary £6,202 pro rata £8.47 pr hour inc holiday pay Age 23+ £18,508 fte (Actual Salary £6,755 pro rata £9.22 pr hour inc "\
            "holiday pay", "£17,007 to £17,391 per year pro rata", "Competitive – discuss with Principal",
            "Main pay range 1, £25,750 to £39,964", "£14,232 to £23,643 per year pro rata", "Main pay range 1, £22,917 to £38,633",
            "MPS/UPS commensurate with experience", "£10,493 to £10,493 per year pro rata", "£17,362 to £17,362 per year pro rata",
            "Pro Rata £13,008 - £13,776 per annum", "£17,364 to £20,138 per year pro rata", "Main/Upper - depending on experience",
            "Main or Upper pay scale with TLR 2.1", "Competitive – discuss with Principal", "Teachers Main Pay Scale - M1 to UPS3",
            "£20,344 to £21,589 per year pro rata", "£20,344 to £21,589 per year pro rata", "Main pay range 1 to Main pay range 6",
            "£12,440 to £13,466 per year pro rata", "Main scale / UPS (suitable for NQTs)", "£17,034 to £18,806 per year pro rata",
            "M1 to UPS3 - £30,480.00 - £49,571.00", "Main pay range 1 to Upper pay range 3, £24,373 to £40,490",
            "Main pay range 1 to Upper pay range 3, £24,859 to £40,520", "MPS-UPS, £25,712 rising to a maximum of £41,604 per annum",
            "Main pay range 1 to Upper pay range 3, £24,373 to £40,490", "Main pay range 1 to Upper pay range 3, £24,373 to £40,490",
            "Main pay range 1 to Upper pay range 3, £27,596 to £43,348", "Main pay range 1 to Upper pay range 3, £23,720 to £39,405",
            "Main pay range 1 to Upper pay range 3, £24,373 to £40,490", "Main pay range 1 to Upper pay range 3, £23,720 to £39,406",
            "Main pay range 1 to Upper pay range 3, £23,720 to £39,406", "Main pay range 1 to Upper pay range 3, £24,373 to £40,490",
            "Salary: Grade 5 £19,312- £19,698 (Actual £15,969-£16,288)", "Main pay range 3 to Upper pay range 3, £29,598 to £43,781",
            "Main pay range 1 to Upper pay range 3, £24,373 to £40,490", "Main pay range 1 to Upper pay range 3, £24,859 to £40,520",
            "Main pay range 1 to Upper pay range 3, £30,480 to £49,571", "Main pay range 2 to Upper pay range 3, £40,000 to £60,000",
            "Main pay range 1 to Upper pay range 3, £24,373 to £40,490", "Main pay range 3 to Upper pay range 3, £27,652 to £39,406",
            "Main pay range 1 to Upper pay range 3, £24,372 to £40,490", "Main pay range 1 to Upper pay range 3, £23,720 to £39,406",
            "£14,922 to £16,152", "£46,430 to £51,234", "£25,750 to £39,964", "£25,714 to £44,604", "Teacher Main Scale",
            "£56,243 to £61,282", "MPS/UPS plusTLR2b ", "£24,373 to £40,490", "£23,720 to £23,720", "£19,945 - £21,166 ",
            "£68,667 to £79,535", "£27,596 to £43,348", "£23,719 to £39,405", "£37,368 to £53,120", "£27,186 - £42,192 ",
            "Teachers Pay Scale", "£29,096 to £39,702", "£27,652 to £39,406", "£23,000 to £40,000", "£23,720 to £39,406",
            "£20,092 to £22,183", "Main pay range £32,157 to £42,624", "£14,787.86 – £18,755.25 per annum",
            "M6 - U1 (Depending on experience)", "MPS/UPS + up to a TLR 2c - £7,017", "Teachers Mainscale (Inner London)",
            "£17,842 L1a  Actual salary £6,537", "Main Scale", "MPS/UPS + London Fringe Allowance"]

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

3.times do
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

2.times do
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
                  school_visits: Faker::Lorem.paragraph(sentence_count: rand(5..10)))

job_titles.delete(la_multiple_schools_job_title)
salaries.delete(la_multiple_schools_salary)

Vacancy.index.clear_index
Vacancy.reindex!

# Jobseekers

## Create jobseeker account that users are accustomed to logging in with
Jobseeker.create(email: "jobseeker@example.com", password: "password", confirmed_at: Time.zone.now)

# Create extra jobseekers so each vacancy has multiple applications

10.times do |i|
  Jobseeker.create(email: "jobseeker#{i}@example.com",
                   password: "password",
                   confirmed_at: Time.zone.now)
end

# Job Applications

Jobseeker.all.each do |jobseeker|
  live_vacancy_ids = Vacancy.live.pluck(:id)
  submitted_statuses = %w[submitted reviewed shortlisted unsuccessful withdrawn]

  5.times do
    job_application = FactoryBot.create(:job_application, "status_#{submitted_statuses.sample}".to_sym,
                                        id: SecureRandom.uuid,
                                        jobseeker: jobseeker,
                                        vacancy: Vacancy.find(live_vacancy_ids.sample))
    submitted_statuses.delete(job_application.status)
    live_vacancy_ids.delete(job_application.vacancy)
  end
end
