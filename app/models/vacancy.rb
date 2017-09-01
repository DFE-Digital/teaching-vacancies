class Vacancy < ApplicationRecord
  include ApplicationHelper

  enum status: [:published, :draft, :trashed]
  enum working_pattern: [:full_time, :part_time]

  belongs_to :school, required: true
  belongs_to :subject
  belongs_to :pay_scale
  belongs_to :leadership

  scope :applicable, -> { where('expires_on >= ?', Time.zone.today) }

  validates :job_title, :job_description, :headline, \
    :minimum_salary, :essential_requirements, :working_pattern, \
    :publish_on, :expires_on, :slug, \
    presence: true

  def location
    [school.name, school.town, school.county].reject(&:blank?).join(', ')
  end

  def salary_range
    return number_to_currency(minimum_salary) unless maximum_salary.present?
    number_to_currency(minimum_salary) + ' - ' + number_to_currency(maximum_salary)
  end
end
