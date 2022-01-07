class Publishers::JobListing::ExpiredFeedbackForm < BaseForm
  attr_accessor :hired_status, :listed_elsewhere

  validates :hired_status, inclusion: { in: Vacancy.hired_statuses.keys }
  validates :listed_elsewhere, inclusion: { in: Vacancy.listed_elsewheres.keys }
end
