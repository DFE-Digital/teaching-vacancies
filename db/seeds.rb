raise if Rails.env.production?

require 'faker'
require 'factory_girl_rails'

london = Region.create(name: 'London')
Region.create(name: 'South East England')
Region.create(name: 'South West England')
Region.create(name: 'Yorkshire and the Humber')
Region.create(name: 'North West England')
Region.create(name: 'West Midlands')
Region.create(name: 'East Midlands')
Region.create(name: 'North East England')

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

academy = SchoolType.create(label: 'Academy')
SchoolType.create(label: 'Independent School')
SchoolType.create(label: 'Free School')
SchoolType.create(label: 'LA Maintained School')
SchoolType.create(label: 'Special School')

Subject.create(name: 'English')
maths = Subject.create(name: 'Mathematics')
science = Subject.create(name: 'Science')
Subject.create(name: 'Art and design')
Subject.create(name: 'Citizenship')
Subject.create(name: 'Computing')
Subject.create(name: 'Design and technology')
Subject.create(name: 'Geography')
Subject.create(name: 'History')
Subject.create(name: 'Languages')
Subject.create(name: 'Music')
Subject.create(name: 'Physical education')

ealing_school = FactoryGirl.create(:school,
                                   name: 'Acme Secondary School',
                                   school_type: academy,
                                   urn: 1234567890,
                                   address: '22 High Street',
                                   town: 'Ealing',
                                   county: 'Middlesex',
                                   postcode: 'EA1 1NG',
                                   region: london)

bromley_school = FactoryGirl.create(:school,
                                    name: 'Bromley High School',
                                    school_type: academy,
                                    urn: 1234567890,
                                    address: '8 London Road',
                                    town: 'Bromley',
                                    county: 'London Borough of Bromley',
                                    postcode: 'BR1 9EY',
                                    region: london)

FactoryGirl.create(:vacancy,
                   job_title: 'Physics Teacher',
                   subject: science,
                   school: ealing_school,
                   minimum_salary: 40000,
                   maximum_salary: 45000,
                   pay_scale: payscale,
                   leadership: leadership)

FactoryGirl.create(:vacancy,
                   job_title: 'Maths Teacher',
                   subject: maths,
                   school: bromley_school,
                   working_pattern: :part_time,
                   minimum_salary: 30000,
                   maximum_salary: 35000,
                   pay_scale: payscale,
                   leadership: leadership)
