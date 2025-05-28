# frozen_string_literal: true

module Publishers
  module Vacancies
    class ReferencesAndDeclarationsController < JobApplications::BaseController
      include Wicked::Wizard

      before_action :set_batch

      FORMS = {
        collect_references: Publishers::JobApplication::CollectReferencesForm,
        ask_references_email: Publishers::JobApplication::ReferencesContactApplicantForm,
      }.freeze

      steps(*FORMS.keys)

      def show
        if step != "wicked_finish"
          @form = form_class.new
        end
        render_wizard
      end

      def update
        @form = form_class.new(params.fetch(form_key, {}).permit(form_class.fields))
        if @form.valid?
          case step
          when :collect_references
            if @form.collect_references_and_declarations
              redirect_to next_wizard_path
            else
              job_applications.each do |job_application|
                job_application.update!(status: :interviewing)
              end
              @batch.destroy!
              redirect_to organisation_job_job_applications_path(vacancy.id, anchor: :interviewing)
            end
          else
            redirect_to next_wizard_path
          end
        else
          render step
        end
      end

      private

      def job_applications
        @batch.batchable_job_applications.map(&:job_application)
      end

      def form_class
        FORMS.fetch(step)
      end

      def form_key
        form_class.to_s.underscore.tr("/", "_")
      end

      def set_batch
        @batch = JobApplicationBatch.where(vacancy: vacancy).find params[:job_application_batch_id]
      end

      def finish_wizard_path
        organisation_job_job_applications_path(vacancy.id, anchor: :interviewing)
      end
    end
  end
end
