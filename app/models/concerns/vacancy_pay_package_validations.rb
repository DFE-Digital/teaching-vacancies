module VacancyPayPackageValidations
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    validates :salary, presence: true
    validates :salary, length: { minimum: 1, maximum: 256 }, if: :salary?
    validate :salary_has_no_tags?, if: :salary?
  end

  def salary_has_no_tags?
    unless salary == sanitize(salary, tags: [])
      errors.add(
        :salary, I18n.t('activemodel.errors.models.pay_package_form.attributes.salary.invalid_characters')
      )
    end
  end
end
