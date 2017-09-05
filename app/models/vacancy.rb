class Vacancy < ApplicationRecord
  include ApplicationHelper

  enum status: %i[published draft trashed]
  enum working_pattern: %i[full_time part_time]

  belongs_to :school, required: true
  belongs_to :subject
  belongs_to :pay_scale
  belongs_to :leadership

  scope :applicable, (-> { where('expires_on >= ?', Time.zone.today) })

  paginates_per 10

  validates :job_title, :job_description, :headline, \
            :minimum_salary, :essential_requirements, :working_pattern, \
            :publish_on, :expires_on, :slug, \
            presence: true

  def location
    [school.name, school.town, school.county].reject(&:blank?).join(', ')
  end

  def salary_range
    return number_to_currency(minimum_salary) if maximum_salary.blank?
    number_to_currency(minimum_salary) +
      ' - ' +
      number_to_currency(maximum_salary)
  end
end
