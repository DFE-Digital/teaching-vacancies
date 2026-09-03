# frozen_string_literal: true

class VacancyTemplateDecorator < Draper::Decorator
  delegate_all

  include ReadableVacancy
end
