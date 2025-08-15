# frozen_string_literal: true

module Publishers
  module Vacancies
    # This is the flow when application is first marked 'interviewing' - ask both questions
    class ReferencesAndSelfDisclosureController < ReferencesAndSelfDisclosureBaseController
      before_action :set_batch, unless: -> { step == Wicked::FINISH_STEP }

      steps(*FORMS.keys)

      def show
        if step != Wicked::FINISH_STEP
          @form = case step
                  when :collect_references
                    form_class.new
                  when :collect_self_disclosure
                    form_class.new collect_references: params[:collect_references]
                  else
                    form_class.new collect_references: params[:collect_references],
                                   collect_self_disclosure: params[:collect_self_disclosure]
                  end
        end
        render_wizard
      end

      # rubocop:disable Metrics/MethodLength
      def update
        @form = form_for_update
        if @form.valid?
          case step
          when :collect_references
            redirect_to next_wizard_path collect_references: @form.collect_references
          when :collect_self_disclosure
            # if both questions are 'no' we go straight to the finish line
            if @form.collect_references || @form.collect_self_disclosure
              redirect_to next_wizard_path collect_references: @form.collect_references,
                                           collect_self_disclosure: @form.collect_self_disclosure
            else
              complete_process
              redirect_to finish_wizard_path
            end
          else
            complete_process
            redirect_to finish_wizard_path
          end
        else
          render step
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def complete_process
        JobApplicationBatch.transaction do
          job_applications.each do |job_application|
            if @form.collect_references
              ReferenceRequest.create_for_external!(job_application)
              Publishers::CollectReferencesMailer.inform_applicant_about_references(job_application).deliver_later if @form.contact_applicants
            else
              ReferenceRequest.create_for_manual!(job_application)
            end
            if @form.collect_self_disclosure
              SelfDisclosureRequest.create_and_notify!(job_application)
            else
              SelfDisclosureRequest.create_for!(job_application)
            end
            job_application.update!(status: :interviewing)
          end
          @batch.destroy!
        end
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
