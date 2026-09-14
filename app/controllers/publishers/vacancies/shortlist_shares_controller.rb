# frozen_string_literal: true

module Publishers
  module Vacancies
    class ShortlistSharesController < BaseController
      before_action :set_vacancy
      before_action :set_job_applications, only: %i[new review create]

      def new
        @form = Publishers::JobApplication::ShortlistShareForm.new(
          job_application_ids: @job_application_ids,
        )
      end

      def review
        @form = Publishers::JobApplication::ShortlistShareForm.new(
          email: shortlist_share_params[:email],
          job_application_ids: @job_application_ids,
        )

        if @form.valid?
          render :review
        else
          render :new, status: :unprocessable_content
        end
      end

      def create
        @form = Publishers::JobApplication::ShortlistShareForm.new(
          email: shortlist_share_params[:email],
          job_application_ids: @job_application_ids,
        )

        if @form.valid?
          Publishers::ShortlistShareMailer
            .shortlist(vacancy.id, @job_application_ids, @form.email, current_publisher.id)
            .deliver_later

          redirect_to organisation_job_job_applications_path(vacancy.id, anchor: :shortlisted), success: t(".success")
        else
          render :new, status: :unprocessable_content
        end
      end

      private

      def set_job_applications
        @job_application_ids = selected_job_application_ids

        if (message = selection_error)
          redirect_with_selection_error(message)
        else
          @job_applications = @selected_job_applications.decorate.sort_by { |application| [application.last_name, application.first_name] }
        end
      end

      def selection_error
        return I18n.t("publishers.vacancies.shortlist_shares.errors.unsupported_application_form") if vacancy.uploaded_form?
        return I18n.t("publishers.vacancies.shortlist_shares.errors.none_selected") if @job_application_ids.empty?

        if @job_application_ids.size > Publishers::JobApplication::ShortlistShareForm::MAX_APPLICATIONS
          return I18n.t(
            "publishers.vacancies.shortlist_shares.errors.too_many",
            count: Publishers::JobApplication::ShortlistShareForm::MAX_APPLICATIONS,
          )
        end

        @selected_job_applications = vacancy.job_applications.where(id: @job_application_ids)
        return if @selected_job_applications.size == @job_application_ids.size && @selected_job_applications.all?(&:shortlisted?)

        I18n.t("publishers.vacancies.shortlist_shares.errors.not_shortlisted")
      end

      def selected_job_application_ids
        ids = params.dig(:publishers_job_application_shortlist_share_form, :job_application_ids) ||
          params.dig(:publishers_job_application_tag_form, :job_applications) ||
          params[:job_application_ids]

        Array(ids).compact_blank.uniq
      end

      def redirect_with_selection_error(message)
        flash[:shortlisted] = message
        redirect_to organisation_job_job_applications_path(vacancy.id, anchor: :shortlisted)
      end

      def shortlist_share_params
        params.expect(publishers_job_application_shortlist_share_form: [:email, { job_application_ids: [] }])
      end
    end
  end
end
