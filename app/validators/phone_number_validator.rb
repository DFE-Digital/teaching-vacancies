# validation logic comes from
# app/form_models/jobseekers/job_application/personal_details_form.rb
# app/form_models/jobseekers/profile/personal_details_form.rb
#

class PhoneNumberValidator < ActiveModel::EachValidator
  PHONE_REGEX = /\A\+?(?:\d\s?){10,13}\z/

  def validate_each(record, attribute, value)
    if value.blank?
      record.errors.add(attribute, :blank)
    elsif !PHONE_REGEX.match?(value)
      record.errors.add(attribute, :invalid)
    end
  end
end
