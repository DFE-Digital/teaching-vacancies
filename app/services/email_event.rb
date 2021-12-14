##
# Represents events occuring as a part of emails being sent to users
#
# This event should only be triggered in mailers.
class EmailEvent < Event
  def initialize(notify_template, email, uid, jobseeker: nil, publisher: nil, ab_tests: nil)
    @notify_template = notify_template
    @email = email
    @uid = uid
    @jobseeker = jobseeker
    @publisher = publisher
    @ab_tests = ab_tests
  end

  private

  attr_reader :notify_template, :email, :uid, :jobseeker, :publisher, :ab_tests

  def base_data
    @base_data ||= super.merge(
      request_ab_tests: ab_tests&.map { |test, variant| { test: test, variant: variant } },
    )
  end

  def data
    @data ||= super.push(
      { key: "uid", value: uid },
      { key: "notify_template", value: notify_template },
      { key: "email_identifier", value: anonymise(email) },
      { key: "user_anonymised_jobseeker_id", value: anonymise(jobseeker&.id) },
      { key: "user_anonymised_publisher_id", value: anonymise(publisher&.oid) },
    )
  end
end
