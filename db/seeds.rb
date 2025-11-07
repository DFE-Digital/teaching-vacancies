raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

Gias::ImportSchoolsAndLocalAuthorities.new.call
Gias::ImportTrusts.new.call

ImportPolygonDataJob.perform_now
SetOrganisationSlugsJob.perform_later

bexleyheath_school = School.find_by!(urn: "137138")
weydon_trust = SchoolGroup.find_by!(uid: "16644")
southampton_la = SchoolGroup.find_by!(local_authority_code: "852")
#  Through school
abraham_moss = School.find_by!(urn: "150009")

# Team users
users = [
  { email: "alex.lee@education.gov.uk", family_name: "Lee", given_name: "Alex" },
  { email: "alice.fitzgibbon@education.gov.uk", family_name: "Fitzgibbon", given_name: "Alice" },
  { email: "alisa.ali@education.gov.uk", family_name: "Ali", given_name: "Alisa" },
  { email: "chloe.ewens@education.gov.uk", family_name: "Ewens", given_name: "Chloe" },
  { email: "david.thacker@education.gov.uk", family_name: "Thacker", given_name: "David" },
  { email: "fisal.yusuf@education.gov.uk", family_name: "Yusuf", given_name: "Fisal" },
  { email: "hannah.vesey-byrne@education.gov.uk", family_name: "Vesey-Byrne", given_name: "Hannah" },
  { email: "james.over@education.gov.uk", family_name: "Over", given_name: "James" },
  { email: "jerome.riga@education.gov.uk", family_name: "Riga", given_name: "Jerome" },
  { email: "kyle.macpherson@education.gov.uk", family_name: "MacPherson", given_name: "Kyle" },
  { email: "marc.sardon@education.gov.uk", family_name: "Sardon", given_name: "Marc" },
  { email: "richard.pattinson@education.gov.uk", family_name: "Pattinson", given_name: "Richard" },
  { email: "sophie.mcmillan@education.gov.uk", family_name: "McMillan", given_name: "Sophie" },
  { email: "stephen.dicks@education.gov.uk", family_name: "Dicks", given_name: "Stephen" },
  { email: "yvonne.ridley@education.gov.uk", family_name: "Ridley", given_name: "Yvonne" },
]

# Schools with phase 'n/a' are tricky to create dynamic vacancies for - they tend to be
# special schools that don't quite fit the primary/secondary/higher pattern
schools = [bexleyheath_school,
           weydon_trust.schools.detect { |s| s.phase != "not_applicable" && s.phase.exclude?("middle") },
           southampton_la.schools.detect { |s| s.phase != "not_applicable" && s.phase.exclude?("middle") },
           abraham_moss]

user_emails = users.map { |u| u.fetch(:email) }

organisations = [bexleyheath_school, weydon_trust, southampton_la, abraham_moss]

users.each do |user|
  publisher = Publisher.create(organisations: organisations, **user)
  organisations.each do |organisation|
    FactoryBot.create(:publisher_preference, publisher: publisher, organisation: organisation)
  end
  SupportUser.create(user)
  FactoryBot.create(:jobseeker, :for_seed_data, email: user[:email])
end

schools.each do |school|
  attrs = { organisations: [school],
            phases: [school.phase],
            publisher_organisation: school,
            publisher: Publisher.all.sample }
  3.times { FactoryBot.create(:vacancy, :for_seed_data, **attrs) }
  FactoryBot.create(:vacancy, :for_seed_data, :no_tv_applications, **attrs)
  2.times { FactoryBot.create(:vacancy, :for_seed_data, :future_publish, **attrs) }
  FactoryBot.create(:draft_vacancy, :for_seed_data, **attrs)
  2.times { FactoryBot.build(:vacancy, :for_seed_data, :expired, **attrs).save(validate: false) }
end

# Vacancies at Weydon trust central office
attrs = { organisations: [weydon_trust], phases: %w[secondary], publisher_organisation: weydon_trust, publisher: Publisher.all.sample }
FactoryBot.create(:vacancy, :for_seed_data, **attrs)

# Vacancies at multiple schools in Weydon trust
attrs = { organisations: weydon_trust.schools, phases: %w[secondary], publisher_organisation: weydon_trust, publisher: Publisher.all.sample }
# need some secondary jobs with subjects sometimes
300.times { FactoryBot.create(:vacancy, :for_seed_data, **attrs) }

# Vacancies at multiple schools in Southampton local authority
attrs = { organisations: southampton_la.schools.first(5), phases: %w[primary], publisher_organisation: southampton_la, publisher: Publisher.all.sample }
FactoryBot.create(:vacancy, :for_seed_data, **attrs)

# Jobseekers
FactoryBot.create(:jobseeker, email: "jobseeker@contoso.com")
50.times { |i| FactoryBot.create(:jobseeker, email: "jobseeker#{i}@contoso.com") }

emails_with_fewer_applications = ["jobseeker@contoso.com"] + user_emails
# Job Applications
statuses = JobApplication.statuses.keys
PublishedVacancy.listed.first(50).each do |vacancy|
  Jobseeker.where.not(email: emails_with_fewer_applications).each do |jobseeker|
    application_status = JobApplication.statuses.keys.sample
    FactoryBot.create(:job_application, :for_seed_data, :"status_#{application_status}",
                      referees: FactoryBot.build_list(:referee, 2, email: emails_with_fewer_applications.sample),
                      jobseeker: jobseeker, vacancy: vacancy)
  end

  # only add 1 fake job application per-status to DFE jobseekers
  random_status = statuses.delete(statuses.sample)
  # Ensures each one of the statuses gets used.
  next unless random_status

  Jobseeker.where(email: emails_with_fewer_applications).each do |jobseeker|
    FactoryBot.create(:job_application, :for_seed_data, :"status_#{random_status}", jobseeker: jobseeker, vacancy: vacancy)
  end
end

## Jobseeker Profiles
location_preference_names = schools.map(&:postcode)

Jobseeker.find_each do |jobseeker|
  Jobseeker.transaction do
    FactoryBot.create(:jobseeker_profile, :with_personal_details,
                      active: true,
                      qualifications: FactoryBot.build_list(:qualification, 1, job_application: nil),
                      employments: FactoryBot.build_list(:employment, 1, :jobseeker_profile_employment),
                      jobseeker: jobseeker) do |jobseeker_profile|
      FactoryBot.create(:job_preferences, jobseeker_profile: jobseeker_profile) do |job_preferences|
        FactoryBot.create(:job_preferences_location, job_preferences:, name: location_preference_names.sample)
      end
    end
  end
end

# still need to delete jobs without an organisation
Vacancy.includes(:organisations).find_each.reject { |v| v.organisation.present? }.each(&:destroy)

# Adds one ATS API Client for testing locally or on review apps
if ENV["ATS_API_CLIENT_TESTING_API_KEY"].present?
  PublisherAtsApiClient.create(name: "Testing ATS Client", api_key: ENV["ATS_API_CLIENT_TESTING_API_KEY"], last_rotated_at: Time.current)
end

stephen = Jobseeker.find_by!(email: "stephen.dicks@education.gov.uk")
postcodes = Vacancy.includes(:organisations).all.map { |x| x.organisation.postcode }.uniq

20_000.times { |i| FactoryBot.create(:daily_subscription, :with_some_criteria, email: stephen.email, radius: i, location: postcodes.sample) }
