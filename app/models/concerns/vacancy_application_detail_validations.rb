module VacancyApplicationDetailValidations
  extend ActiveSupport::Concern

  included do
    validates :contact_email, presence: true
    validates :contact_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: :contact_email?

    validates :application_link, url: true, if: :application_link?
  end
end
