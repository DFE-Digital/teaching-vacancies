['Chemistry', 'Economics', 'General Science',
'History', 'Maths', 'Other',
'Primary', 'Spanish', 'Art',
'Classics', 'English Language', 'Geography',
'ICT', 'Media Studies', 'Physical Education',
'Psychology', 'Statistics', 'Biology',
'Design Technology', 'English Literature', 'German',
'Latin', 'Music', 'Physics',
'Religious Studies', 'Business Studies', 'Drama',
'French', 'Health and Social care', 'Law',
'Politics', 'Sociology'].each do |subject|
  Subject.create(name: subject)
end

raise if Rails.env.production?

require 'faker'
require 'factory_bot_rails'

london = Region.create(name: 'London', code: 'H')
se = Region.create(name: 'South East England', code: 'J')
Region.create(name: 'South West England', code: 'K')
Region.create(name: 'Yorkshire and the Humber', code: 'D')
Region.create(name: 'North West England', code: 'B')
Region.create(name: 'West Midlands', code: 'F')
Region.create(name: 'East Midlands', code: 'E')
Region.create(name: 'North East England', code: 'A')

academy = SchoolType.create(label: 'Academy', code: '10')
community_school = SchoolType.create(label: 'Community School', code: '1')
SchoolType.create(label: 'Independent School', code: '3')
SchoolType.create(label: 'Free School', code: '11')
SchoolType.create(label: 'LA Maintained School', code: '4')
SchoolType.create(label: 'Special School', code: '5')


ealing_school = FactoryBot.create(:school, name: 'Macmillan Academy ',
                                   school_type: academy,
                                   urn: 137138,
                                   address: 'Stockton Road',
                                   phase: :secondary,
                                   town: 'Middlesbrough',
                                   postcode: 'TS5 4AG',
                                   url: 'http://www.macmillan-academy.org.uk',
                                   region: london,
                                   geolocation: '(54.565770,-1.264489)')

bromley_school = FactoryBot.create(:school,
                                    name: 'Burnsfield Infant School',
                                    school_type: community_school,
                                    urn: 110628,
                                    address: 'Burnsfield Estate',
                                    phase: :primary,
                                    town: 'Chatteris',
                                    county: 'Cambridgeshire',
                                    postcode: 'PE16 6ET',
                                    region: se,
                                    geolocation: '(52.455421,0.043325)')

payscale = PayScale.limit(5).sample(1).first
leadership = Leadership.limit(1).sample(1).first

FactoryBot.create(:vacancy,
                   job_title: 'Physics Teacher',
                   subject: Subject.first,
                   school: ealing_school,
                   minimum_salary: 40000,
                   maximum_salary: 45000,
                   min_pay_scale: payscale,
                   leadership: leadership)

FactoryBot.create(:vacancy,
                   job_title: 'Maths Teacher',
                   subject: Subject.last,
                   school: bromley_school,
                   working_pattern: :part_time,
                   minimum_salary: 30000,
                   maximum_salary: 35000,
                   min_pay_scale: payscale,
                   leadership: leadership)

FactoryBot.create(:vacancy,
                   job_title: 'PE Teacher',
                   subject: Subject.last,
                   school: ealing_school,
                   working_pattern: :part_time,
                   minimum_salary: 30000,
                   maximum_salary: 35000,
                   min_pay_scale: payscale,
                   leadership: leadership)

FactoryBot.create(:vacancy,
                   job_title: 'Geography Teacher',
                   subject: Subject.last,
                   school: ealing_school,
                   working_pattern: :part_time,
                   minimum_salary: 30000,
                   maximum_salary: 35000,
                   min_pay_scale: payscale,
                   status: 1,
                   leadership: leadership)

# pending vacancy
FactoryBot.create(:vacancy,
                  job_title: 'Teacher of Drama',
                  subject: Subject.last,
                  school: ealing_school,
                  minimum_salary: 30000,
                  maximum_salary: 35000,
                  min_pay_scale: payscale,
                  leadership: leadership,
                  publish_on: Time.zone.today + 1.year,
                  expires_on: Time.zone.today + 2.years)

# expired vacancy
expired = FactoryBot.build(:vacancy,
                  job_title: 'Subject lead in Art',
                  subject: Subject.last,
                  school: ealing_school,
                  minimum_salary: 30000,
                  maximum_salary: 35000,
                  min_pay_scale: payscale,
                  leadership: leadership,
                  expires_on: Time.zone.today - 2.days)
expired.send :set_slug
expired.save(validate: false)

20.times { FactoryBot.create(:vacancy) }
