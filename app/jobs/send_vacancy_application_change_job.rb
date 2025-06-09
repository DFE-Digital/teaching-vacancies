class SendVacancyApplicationChangeJob < ApplicationJob
  queue_as :default

  def perform
    Vacancy
      .includes(:publisher)
      .where(
        receive_applications: :email,
        created_at: 18.months.ago...,
      )
      .select(:contact_email).distinct
      .select("*")
      .find_each do |vacancy|
        Publishers::VacancyChangeMailer.notify(vacancy:).deliver_later
      end
  end
end
