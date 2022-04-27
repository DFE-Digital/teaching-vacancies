class Publishers::JobListing::SelectAJobForCopyingForm < BaseForm
  attr_accessor :vacancy_id

  validates :vacancy_id, presence: true
end
