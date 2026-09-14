# frozen_string_literal: true

class Publishers::JobApplication::ShortlistShareForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  MAX_APPLICATIONS = 8

  attribute :email, :string
  attr_accessor :job_application_ids

  validates :email, presence: true, email_address: true
  validates :job_application_ids,
            length: {
              minimum: 1,
              maximum: MAX_APPLICATIONS,
              too_long: ->(_object, data) { I18n.t("publishers.vacancies.shortlist_shares.errors.too_many", count: data[:count]) },
            }
end
