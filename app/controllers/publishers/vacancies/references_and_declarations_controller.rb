# frozen_string_literal: true

module Publishers
  module Vacancies
    class ReferencesAndDeclarationsController < JobApplications::BaseController
      include Wicked::Wizard

      before_action :set_batch, unless: -> { step == Wicked::FINISH_STEP }

      FORMS = {
        collect_references: Publishers::JobApplication::CollectReferencesForm,
        ask_references_email: Publishers::JobApplication::ReferencesContactApplicantForm,
      }.freeze

      steps(*FORMS.keys)

      def show
        if step != Wicked::FINISH_STEP
          @form = form_class.new
        end
        render_wizard
      end

      def update
        form_key = ActiveModel::Naming.param_key(form_class)
        @form = form_class.new(params.fetch(form_key, {}).permit(form_class.fields))
        if @form.valid?
          if step == :collect_references
            if @form.collect_references_and_declarations
              redirect_to next_wizard_path
            else
              complete_process
              redirect_to finish_wizard_path
            end
          else
            # there are only 2 steps, so this one is the end by definition
            complete_process
            redirect_to finish_wizard_path
          end
        else
          render step
        end
      end

      private

      def complete_process
        JobApplicationBatch.transaction do
          job_applications.each do |job_application|
            if step == :collect_references
              SelfDisclosureRequest.create_for!(job_application)
              ReferenceRequest.create_for_manual!(job_application)
            else
              SelfDisclosureRequest.create_and_notify!(job_application)
              Publishers::CollectReferencesMailer.inform_applicant_about_references(job_application).deliver_later if @form.contact_applicants
              ReferenceRequest.create_for_external!(job_application)
            end
            job_application.update!(status: :interviewing)
          end
          @batch.destroy!
        end
      end

      def form_class
        FORMS.fetch(step)
      end

      def job_applications
        @batch.batchable_job_applications.map(&:job_application)
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
