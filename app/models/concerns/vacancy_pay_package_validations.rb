module VacancyPayPackageValidations
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    validates :salary, presence: true
    validates :salary, length: { minimum: 1, maximum: 256 }, if: :salary?
  end

  def salary=(value)
    super(sanitize(value, tags: []))
  end
end
