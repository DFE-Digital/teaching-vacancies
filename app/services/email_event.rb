##
# Represents events occuring as a part of emails being sent to users
#
# This event should only be triggered in mailers.
class EmailEvent < Event
  def initialize(notify_template, email, jobseeker: nil, publisher: nil)
    @notify_template = notify_template
    @email = email
    @jobseeker = jobseeker
    @publisher = publisher
  end

  private

  attr_reader :notify_template, :email, :jobseeker, :publisher

  def base_data
    @base_data ||= super.merge(
      notify_template: notify_template,
      email_identifier: anonymise(email),
      user_anonymised_jobseeker_id: anonymise(jobseeker&.id),
      user_anonymised_publisher_id: anonymise(publisher&.oid),
    )
  end
end
