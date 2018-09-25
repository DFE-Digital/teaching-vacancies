class Subject < ApplicationRecord
  has_many :vacancies

  default_scope { order(:name) }
end
