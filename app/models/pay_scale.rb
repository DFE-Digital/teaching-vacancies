class PayScale < ApplicationRecord
  has_many :vacancies

  default_scope { order(:index) }
end
