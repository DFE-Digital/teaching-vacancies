class JobPosting
  def initialize(schema)
    @schema = schema
  end

  def to_vacancy
    Vacancy.new(map_schema_to_vacancy_fields)
  end

  private

  def map_schema_to_vacancy_fields
    {
      job_title: @schema['title'],
      job_roles: @schema['occupationalCategory'].split(', '),
      salary: @schema['salary'],
      benefits: @schema['jobBenefits'],
      education: @schema['educationRequirements'],
      qualifications: @schema['qualifications'],
      experience: @schema['experienceRequirements'],
      working_patterns: @schema['employmentType'].split(', ').map(&:downcase),
      status: :published,
      application_link: @schema['url'],
      contact_email: 'recruitment@school.invalid',
      publish_on: publish_on_or_today,
      expires_on: expires_on_or_future,
      job_summary: @schema['description'],
      about_organisation: @schema['hiringOrganization']['description'],
      school: school_by_urn_or_random
    }
  end

  def school_by_urn_or_random
    School.find_by(urn: @schema['hiringOrganization']['identifier']) || random_school
  end

  def random_school
    School.offset(rand(School.count)).first
  end

  def publish_on_or_today
    publish_on = Time.zone.parse(@schema['datePosted'])
    publish_on.past? ? Time.zone.now : publish_on
  end

  def expires_on_or_future
    expires_on = Time.zone.parse(@schema['validThrough'])
    expires_on.future? ? expires_on : 4.months.from_now
  end
end
