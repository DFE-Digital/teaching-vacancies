class SendJobApplicationDataExpiryNotificationJob < ApplicationJob
  queue_as :default

  def perform
    start_of_today = DateTime.now.in_time_zone(Time.zone).beginning_of_day
    end_of_today = DateTime.now.in_time_zone(Time.zone).end_of_day
    two_weeks_less_than_a_year_ago = 1.year - 2.weeks

    two_weeks_until_expiry = (start_of_today - two_weeks_less_than_a_year_ago)..(end_of_today - two_weeks_less_than_a_year_ago)

    vacancies_with_two_weeks_until_expiry = Vacancy.expired.includes(organisations: :publishers).where(expires_at: two_weeks_until_expiry)

    vacancies_with_two_weeks_until_expiry.each do |vacancy|
      vacancy.organisation.publishers.each do |publisher|
        Publishers::JobApplicationDataExpiryNotification.with(vacancy: vacancy, publisher: publisher).deliver(publisher) if publisher.email == "joseph.hull@digital.education.gov.uk"
      end
    end
  end
end
