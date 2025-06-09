class SendVacancyApplicationChangeJob < ApplicationJob
  queue_as :default

  def perform
    Publisher
      .joins(:vacancies)
      .where(
        vacancies: {
          receive_applications: :email,
          created_at: 18.months.ago...,
        },
      )
      .distinct
      .find_each do |publisher|
      Publishers::VacancyChangeMailer.notify(publisher:).deliver_later
    end
  end
end
