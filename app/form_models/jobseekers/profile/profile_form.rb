class Jobseekers::Profile::ProfileForm < BaseForm
  attr_accessor :params, :jobseeker_profile, :completed_steps

  def initialize(params = {}, jobseeker_profile = nil)
    @params = params
    @jobseeker_profile = jobseeker_profile

    super(params)
  end
end
