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
    personal_details_record.assign_attributes(form.attributes.compact)
    personal_details_record.save!
  end

  def personal_details_record
    @personal_details_record ||= profile.personal_details || profile.build_personal_details
  end

  def attributes_from_store
    personal_details_record.attributes.slice(*self.class.multistep_form.attribute_names)
  end
end
