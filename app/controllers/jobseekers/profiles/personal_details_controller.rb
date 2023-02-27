require "multistep/controller"

class Jobseekers::Profiles::PersonalDetailsController < Jobseekers::ProfilesController
  include Multistep::Controller

  multistep_form Jobseekers::Profile::PersonalDetailsForm, key: :personal_details_form

  escape_path { jobseekers_profile_path }

  def complete
    render "review"
  end

  private

  def store_form!
    personal_details_record.update!(form.attributes.compact)
  end

  def personal_details_record
    @personal_details_record ||= PersonalDetails.find_or_create_by(jobseeker_profile_id: current_jobseeker.jobseeker_profile.id)
  end

  def attributes_from_store
    personal_details_record.attributes.slice(*self.class.multistep_form.attribute_names)
  end
end