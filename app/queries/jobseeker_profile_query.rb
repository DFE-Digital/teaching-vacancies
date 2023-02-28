class JobseekerProfileQuery
  def initialize(params, organisation)
    @params = params
    @organisation = organisation
  end

  def call
    JobseekerProfile.all
  end
end
