# frozen_string_literal: true

module Publishers
  module Vacancies
    class FormPreviewsController < Publishers::Vacancies::BaseController
      before_action :set_vacancy

      def show
        document = ::DocumentPreviewService.call(params[:id], vacancy)
        send_data(document.data, filename: document.filename, disposition: "inline")
      end
    end
  end
end
