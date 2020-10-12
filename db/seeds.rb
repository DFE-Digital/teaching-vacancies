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

academy_type = SchoolType.create(label: 'Academy', code: '10')
community_school_type = SchoolType.create(label: 'Community School', code: '1')
SchoolType.create(label: 'Independent School', code: '3')
SchoolType.create(label: 'Free School', code: '11')
SchoolType.create(label: 'LA Maintained School', code: '4')
SchoolType.create(label: 'Special School', code: '5')

academy = FactoryBot.create(:school,
                            address: 'Stockton Road',
                            geolocation: '(54.565770,-1.264489)',
                            gias_data: { 'ReligiousCharacter (name)': 'None' },
                            name: 'Macmillan Academy',
                            phase: :secondary,
                            postcode: 'TS5 4AG',
                            region: 'London',
                            school_type: academy_type,
                            town: 'Middlesbrough',
                            url: 'http://www.macmillan-academy.org.uk',
                            urn: 137138)

community_school = FactoryBot.create(:school,
                                     address: 'Burnsfield Estate',
                                     county: 'Cambridgeshire',
                                     geolocation: '(52.455421,0.043325)',
                                     gias_data: { 'ReligiousCharacter (name)': 'Roman Catholic' },
                                     name: 'Burnsfield Infant School',
                                     phase: :primary,
                                     postcode: 'PE16 6ET',
                                     region: 'South East England',
                                     school_type: community_school_type,
                                     town: 'Chatteris',
                                     urn: 110628)

leadership = Leadership.limit(1).sample(1).first

FactoryBot.create(:vacancy,
                  job_title: 'Physics Teacher',
                  subject: Subject.find_by!(name: 'Physics'),
                  school: academy,
                  working_patterns: ['full_time', 'job_share'],
                  salary: '£35,000',
                  leadership: leadership)

FactoryBot.create(:vacancy,
                  job_title: 'Maths Teacher',
                  subject: Subject.find_by!(name: 'Maths'),
                  school: community_school,
                  working_patterns: ['part_time'],
                  salary: '£35,000',
                  leadership: leadership)

FactoryBot.create(:vacancy,
                  job_title: 'PE Teacher',
                  subject: Subject.find_by!(name: 'Physical Education'),
                  school: academy,
                  working_patterns: ['part_time'],
                  salary: '£30,000',
                  leadership: leadership,
                  total_pageviews: 4,
                  total_get_more_info_clicks: 2)

FactoryBot.create(:vacancy,
                  job_title: 'Chemistry Teacher',
                  subject: Subject.find_by!(name: 'Chemistry'),
                  school: academy,
                  working_patterns: ['full_time', 'part_time'],
                  salary: '£55,000',
                  leadership: leadership)

FactoryBot.create(:vacancy,
                  job_title: 'Geography Teacher',
                  subject: Subject.find_by!(name: 'Geography'),
                  school: academy,
                  working_patterns: ['part_time', 'job_share'],
                  salary: '£25,000',
                  status: 1,
                  leadership: leadership)

# pending vacancy
FactoryBot.create(:vacancy,
                  job_title: 'Teacher of Drama',
                  subject: Subject.find_by!(name: 'Drama'),
                  school: academy,
                  salary: '£28,000',
                  leadership: leadership,
                  publish_on: Time.zone.today + 1.year,
                  expires_on: Time.zone.today + 2.years,
                  starts_on: Time.zone.today + 3.years,
                )

# expired vacancy
expired_one = FactoryBot.build(:vacancy,
                               job_title: 'Subject lead in Art',
                               subject: Subject.find_by!(name: 'Art'),
                               school: academy,
                               working_patterns: ['full_time', 'part_time', 'job_share'],
                               salary: '£32,000',
                               leadership: leadership,
                               publish_on: Time.zone.today - 5.days,
                               expires_on: Time.zone.today - 2.days)
expired_one.send :set_slug
expired_one.save(validate: false)

expired_two = FactoryBot.build(:vacancy,
                               job_title: 'Subject lead in Drama',
                               subject: Subject.find_by!(name: 'Drama'),
                               school: academy,
                               working_patterns: ['full_time', 'part_time', 'job_share'],
                               salary: '£46,000',
                               leadership: leadership,
                               publish_on: Time.zone.today - 5.days,
                               expires_on: Time.zone.today - 2.days)
expired_two.send :set_slug
expired_two.save(validate: false)

expired_three = FactoryBot.build(:vacancy,
                                 job_title: 'Subject lead in Maths',
                                 subject: Subject.find_by!(name: 'Maths'),
                                 school: academy,
                                 working_patterns: ['full_time', 'part_time', 'job_share'],
                                 salary: '£28,000',
                                 leadership: leadership,
                                 publish_on: Time.zone.today - 5.days,
                                 expires_on: Time.zone.today - 2.days)
expired_three.send :set_slug
expired_three.save(validate: false)

20.times { FactoryBot.create(:vacancy) }
