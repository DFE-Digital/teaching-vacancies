class Vacancy < ApplicationRecord
  belongs_to :school, required: true
  belongs_to :subject
  belongs_to :pay_scale
  belongs_to :leadership

  validates :job_title, :job_description, :headline, \
    :minimum_salary, :essential_requirements, :working_pattern, \
    :publish_on, :expires_on, \
    presence: true
end
