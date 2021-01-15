class ApplyingForTheJobForm < VacancyForm
  validates :application_link, url: true, if: :application_link?

  validates :contact_email, presence: true
  validates :contact_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: :contact_email?

  validates :contact_number, format: { with: /\A\+?(?:\d\s?){10,12}\z/ }, if: :contact_number?
end
