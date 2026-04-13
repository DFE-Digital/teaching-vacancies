module Jobseekers
  module UploadedJobApplication
    class UploadApplicationFormForm < Jobseekers::JobApplication::BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Jobseekers::JobApplication::CompletedFormAttribute

      validates :application_form, form_file: Vacancy::DOCUMENT_VALIDATION_OPTIONS.merge(skip_google_drive_virus_check: true)
      validates :application_form, presence: true, if: -> { upload_application_form_section_completed }
      validate :existing_application_form_scan_safe

      completed_attribute(:upload_application_form)

      attr_accessor :application_form

      class << self
        def load_form(model)
          completed_attrs(model, :upload_application_form).merge(application_form: model.application_form)
        end
      end

      private

      def existing_application_form_scan_safe
        return unless application_form.respond_to?(:blob)

        blob = application_form.blob
        errors.add(:application_form, :unsafe_file) if blob.malware_scan_malicious? || blob.malware_scan_scan_error?
      end
    end
  end
end
