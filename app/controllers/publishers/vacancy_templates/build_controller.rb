# frozen_string_literal: true

module Publishers
  module VacancyTemplates
    class BuildController < Publishers::BaseController
      include Wicked::Wizard

      steps :name

      def show
        render_wizard
      end
    end
  end
end
