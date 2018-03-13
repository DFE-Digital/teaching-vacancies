raise if Rails.env.production?

require 'faker'
require 'factory_girl_rails'

london = Region.create(name: 'London', code: 'H')
Region.create(name: 'South East England', code: 'J')
Region.create(name: 'South West England', code: 'K')
Region.create(name: 'Yorkshire and the Humber', code: 'D')
Region.create(name: 'North West England', code: 'B')
Region.create(name: 'West Midlands', code: 'F')
Region.create(name: 'East Midlands', code: 'E')
Region.create(name: 'North East England', code: 'A')

payscale = PayScale.create(label: 'Main pay range 1')
PayScale.create(label: 'Main pay range 2')
PayScale.create(label: 'Main pay range 3')
PayScale.create(label: 'Main pay range 4')
PayScale.create(label: 'Main pay range 5')
PayScale.create(label: 'Main pay range 6')
PayScale.create(label: 'Upper pay range 1')
PayScale.create(label: 'Upper pay range 2')
PayScale.create(label: 'Upper pay range 3')

Leadership.create(title: 'Middle Leader')
leadership = Leadership.create(title: 'Senior Leader')
Leadership.create(title: 'Headteacher')
Leadership.create(title: 'Executive Head')
Leadership.create(title: 'Multi-Academy Trust')

academy = SchoolType.create(label: 'Academy', code: '10')
SchoolType.create(label: 'Independent School', code: '3')
SchoolType.create(label: 'Free School', code: '11')
SchoolType.create(label: 'LA Maintained School', code: '4')
SchoolType.create(label: 'Special School', code: '5')

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

 ealing_school = FactoryGirl.create(:school, name: 'Acme Secondary School',
                                    school_type: academy,
                                    urn: 1234567890,
                                    address: '22 High Street',
                                    town: 'Ealing',
                                    county: 'Middlesex',
                                    postcode: 'EA1 1NG',
                                    region: london,
                                    geolocation: '(51.395261, 0.056949)')

 bromley_school = FactoryGirl.create(:school,
                                     name: 'Bromley High School',
                                     school_type: academy,
                                     urn: 1234567890,
                                     address: '8 London Road',
                                     town: 'Bromley',
                                     county: 'London Borough of Bromley',
                                     postcode: 'BR1 9EY',
                                     region: london,
                                     geolocation: '(51.395261, 0.056949)')

 FactoryGirl.create(:vacancy,
                    job_title: 'Physics Teacher',
                    subject: Subject.first,
                    school: ealing_school,
                    minimum_salary: 40000,
                    maximum_salary: 45000,
                    pay_scale: payscale,
                    leadership: leadership)

 FactoryGirl.create(:vacancy,
                    job_title: 'Maths Teacher',
                    subject: Subject.last,
                    school: bromley_school,
                    working_pattern: :part_time,
                    minimum_salary: 30000,
                    maximum_salary: 35000,
                    pay_scale: payscale,
                    leadership: leadership)
