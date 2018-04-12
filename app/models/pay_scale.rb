class PayScale < ApplicationRecord
  has_many :vacancies

  default_scope { order(:index) }

  def self.minimum_payscale_salary
    PayScale.minimum(:salary).to_i
  end
end
