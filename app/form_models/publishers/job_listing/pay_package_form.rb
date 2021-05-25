class Publishers::JobListing::PayPackageForm < Publishers::JobListing::VacancyForm
  include ActionView::Helpers::SanitizeHelper

  attr_accessor :salary, :benefits

  validates :salary, presence: true
  validates :salary, length: { minimum: 1, maximum: 256 }, if: proc { salary.present? }
  validate :salary_has_no_tags?, if: proc { salary.present? }

  def salary_has_no_tags?
    salary_with_not_escaped_characters = salary.delete("&")
    return if salary_with_not_escaped_characters == sanitize(salary_with_not_escaped_characters, tags: [])

    errors.add(:salary, I18n.t("pay_package_errors.salary.invalid_characters"))
  end
end
