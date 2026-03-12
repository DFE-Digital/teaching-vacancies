# frozen_string_literal: true

module Publishers
  class VacancyTemplatesController < Publishers::BaseController
    def index
      # TODO: scope by publisher/organisation
      @templates = VacancyTemplate.all
    end
  end
end
