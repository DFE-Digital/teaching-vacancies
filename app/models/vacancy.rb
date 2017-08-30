class Vacancy < ApplicationRecord
  belongs_to :school, required: true
  belongs_to :subject
  belongs_to :pay_scale
  belongs_to :leadership
end
