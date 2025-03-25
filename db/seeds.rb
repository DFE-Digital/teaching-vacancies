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
#  Oakfield Academy is middle deemed secondary
oakfield = School.find_by!(urn: "136970")
# Avanti Park is middle deeemd primary
avanti = School.find_by!(urn: "147651")
#  Through school
abraham_moss = School.find_by!(urn: "150009")

# Team users
users = [
  { email: "alan.arnfeld@education.gov.uk", family_name: "Alan", given_name: "Arnfeld" },
  { email: "alisa.ali@education.gov.uk", family_name: "Ali", given_name: "Alisa" },
  { email: "brandon1.chan@education.gov.uk", family_name: "Chan", given_name: "Brandon" },
  { email: "chloe.ewens@education.gov.uk", family_name: "Ewens", given_name: "Chloe" },
  { email: "davide.dippolito@education.gov.uk", family_name: "Dippolito", given_name: "Davide" },
  { email: "ellie.nodder@education.gov.uk", family_name: "Nodder", given_name: "Ellie" },
  { email: "fisal.yusuf@education.gov.uk", family_name: "Yusuf", given_name: "Fisal" },
  { email: "halima.ikuomola@education.gov.uk", family_name: "Ikuomola", given_name: "Halima" },
  { email: "hannah.vesey-byrne@education.gov.uk", family_name: "Vesey-Byrne", given_name: "Hannah" },
  { email: "jerome.riga@education.gov.uk", family_name: "Riga", given_name: "Jerome" },
  { email: "kyle.macpherson@education.gov.uk", family_name: "MacPherson", given_name: "Kyle" },
  { email: "marc.sardon@education.gov.uk", family_name: "Sardon", given_name: "Marc" },
  { email: "sophie.mcmillan@education.gov.uk", family_name: "McMillan", given_name: "Sophie" },
  { email: "stephanie.maskery@education.gov.uk", family_name: "Maskery", given_name: "Stephanie" },
  { email: "stephen.dicks@education.gov.uk", family_name: "Dicks", given_name: "Stephen" },
  { email: "yvonne.ridley@education.gov.uk", family_name: "Yvonne", given_name: "Ridley" },
]

users.each do |user|
  Publisher.create(organisations: [bexleyheath_school, weydon_trust, southampton_la, oakfield, avanti, abraham_moss], **user)
  SupportUser.create(user)
  FactoryBot.create(:jobseeker, email: user[:email])
end

# Vacancies at Bexleyheath school
attrs = { organisations: [bexleyheath_school], phases: [bexleyheath_school.phase], publisher_organisation: bexleyheath_school, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :for_seed_data, :published, **attrs) }
2.times { FactoryBot.create(:vacancy, :for_seed_data, :published, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :for_seed_data, :future_publish, **attrs) }
2.times { FactoryBot.create(:vacancy, :for_seed_data, :draft, **attrs) }
4.times { FactoryBot.build(:vacancy, :for_seed_data, :expired, **attrs).save(validate: false) }

# Vacancies at a school that belongs to Weydon Multi Academy Trust
school = weydon_trust.schools.first
attrs = { organisations: [school], phases: ["secondary"], publisher_organisation: school, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :for_seed_data, :published, **attrs) }
2.times { FactoryBot.create(:vacancy, :for_seed_data, :published, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :for_seed_data, :future_publish, **attrs) }
2.times { FactoryBot.create(:vacancy, :for_seed_data, :draft, **attrs) }
4.times { FactoryBot.build(:vacancy, :for_seed_data, :expired, **attrs).save(validate: false) }

# Vacancies at a school that belongs to Southampton local authority
school = southampton_la.schools.first
attrs = { organisations: [school], phases: ["primary"], publisher_organisation: school, publisher: Publisher.all.sample }
6.times { FactoryBot.create(:vacancy, :for_seed_data, :published, **attrs) }
2.times { FactoryBot.create(:vacancy, :for_seed_data, :published, :no_tv_applications, **attrs) }
4.times { FactoryBot.create(:vacancy, :for_seed_data, :future_publish, **attrs) }
2.times { FactoryBot.create(:vacancy, :for_seed_data, :draft, **attrs) }
4.times { FactoryBot.build(:vacancy, :for_seed_data, :expired, **attrs).save(validate: false) }

# Vacancies at Weydon trust central office
attrs = { organisations: [weydon_trust], phases: %w[secondary], publisher_organisation: weydon_trust, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :for_seed_data, :published, **attrs) }

# Vacancies at multiple schools in Weydon trust
attrs = { organisations: weydon_trust.schools, phases: %w[secondary], publisher_organisation: weydon_trust, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :for_seed_data, :published, **attrs) }

# Vacancies at multiple schools in Southampton local authority
attrs = { organisations: southampton_la.schools.first(5), phases: %w[primary], publisher_organisation: southampton_la, publisher: Publisher.all.sample }
3.times { FactoryBot.create(:vacancy, :for_seed_data, :published, **attrs) }

# Jobseekers
FactoryBot.create(:jobseeker, email: "jobseeker@contoso.com")
JobApplication.statuses.count.times { |i| FactoryBot.create(:jobseeker, email: "jobseeker#{i}@contoso.com") }

# Job Applications
Vacancy.listed.each do |vacancy|
  statuses = JobApplication.statuses.keys
  Jobseeker.where.not(email: "jobseeker@contoso.com").each do |jobseeker|
    # Ensures each one of the statuses gets used. When no unused statuses are left, takes random ones from the list for further new applications.
    application_status = statuses.delete(statuses.sample) || JobApplication.statuses.keys.sample
    FactoryBot.create(:job_application, :for_seed_data, :"status_#{application_status}", jobseeker: jobseeker, vacancy: vacancy)
  end
end

## Jobseeker Profiles
weydon_trust_schools = weydon_trust.schools.all
location_preference_names = weydon_trust_schools.map(&:postcode)

Jobseeker.first(weydon_trust_schools.count).each do |jobseeker|
  Jobseeker.transaction do
    FactoryBot.create(:jobseeker_profile, :with_personal_details,
                      qualifications: FactoryBot.build_list(:qualification, 1,
                                                            job_application: FactoryBot.build(:job_application,
                                                                                              vacancy: FactoryBot.build(:vacancy,
                                                                                                                        organisations: weydon_trust_schools))),
                      employments: FactoryBot.build_list(:employment, 1, :jobseeker_profile_employment),
                      jobseeker: jobseeker) do |jobseeker_profile|
      FactoryBot.create(:job_preferences, jobseeker_profile: jobseeker_profile) do |job_preferences|
        FactoryBot.create(:job_preferences_location, job_preferences:, name: location_preference_names.pop)
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
