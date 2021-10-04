class OrganisationVacancy < ApplicationRecord
  belongs_to :organisation
  belongs_to :vacancy
end
