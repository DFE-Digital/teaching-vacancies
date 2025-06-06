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
        if step != Wicked::FINISH_STEP
          @form = form_class.new
        end
        render_wizard
      end

      def update
        @form = form_class.new(params.fetch(form_key, {}).permit(form_class.fields))
        if @form.valid?
          if step == :collect_references
            if @form.collect_references_and_declarations
              redirect_to next_wizard_path
            else
              SelfDisclosureRequest.create_all!(job_applications)
              update_completed
              redirect_to finish_wizard_path
            end
          else
            SelfDisclosureRequest.create_and_notify_all!(job_applications)
            update_completed
            redirect_to finish_wizard_path
          end
        else
          render step
        end
      end

      private

      def update_completed
        JobApplicationBatch.transaction do
          job_applications.each do |job_application|
            if step == :collect_references
              job_application.referees.reject { |r| r.reference_request.present? }.each do |referee|
                referee.create_reference_request!(token: SecureRandom.uuid, status: :created)
              end
            else
              Publishers::CollectReferencesMailer.inform_applicant_about_references(job_application).deliver_later if @form.contact_applicants
              job_application.referees.each do |referee|
                reference_request = create_reference_request(referee)
                reference = referee.create_job_reference!
                Publishers::CollectReferencesMailer.collect_references(reference, reference_request.token).deliver_later
              end
            end
            job_application.update!(status: :interviewing)
          end
          @batch.destroy!
        end
      end

      def form_class
        FORMS.fetch(step)
      end

      def form_key
        ActiveModel::Naming.param_key(form_class)
      end

      def job_applications
        @batch.batchable_job_applications.map(&:job_application)
      end

      def create_reference_request(referee)
        if referee.reference_request.present?
          referee.reference_request.tap do |rr|
            rr.update!(status: :requested)
          end
        else
          referee.create_reference_request!(token: SecureRandom.uuid, status: :requested)
        end
      end

      def set_batch
        @batch = JobApplicationBatch.where(vacancy: vacancy).find params[:job_application_batch_id] unless step == Wicked::FINISH_STEP
      end

      def finish_wizard_path
        organisation_job_job_applications_path(vacancy.id, anchor: :interviewing)
      end
    end
  end
end
