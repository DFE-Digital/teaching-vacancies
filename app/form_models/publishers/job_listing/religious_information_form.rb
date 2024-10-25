# frozen_string_literal: true

class Publishers::JobListing::ReligiousInformationForm < Publishers::JobListing::VacancyForm
  validates_presence_of :religion_type

  def self.fields
    %i[religion_type]
  end
  attr_accessor(*fields)

  def params_to_save
    params
  end
end
