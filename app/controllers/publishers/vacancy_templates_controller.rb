# frozen_string_literal: true

module Publishers
  class VacancyTemplatesController < Publishers::BaseController
    def index
      @vacancy_types = %i[live draft pending expired awaiting_feedback]

      # TODO: scope by publisher/organisation
      @templates = VacancyTemplate.all
      @count = @templates.count
    end
  end
end
