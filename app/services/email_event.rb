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

  def data
    @data ||= super.push(
      { key: "notify_template", value: notify_template },
      { key: "email_identifier", value: anonymise(email) },
      { key: "user_anonymised_jobseeker_id", value: anonymise(jobseeker&.id) },
      { key: "user_anonymised_publisher_id", value: anonymise(publisher&.oid) },
    )
  end
end
