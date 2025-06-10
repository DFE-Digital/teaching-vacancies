module Jobseekers
  module UploadedJobApplication
    class UploadApplicationFormForm < Jobseekers::JobApplication::BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Jobseekers::JobApplication::CompletedFormAttribute

      validates :application_form, form_file: Vacancy::DOCUMENT_VALIDATION_OPTIONS
      validate :application_form_presence, if: -> { upload_application_form_section_completed }

      completed_attribute(:upload_application_form)

      attr_accessor :application_form

      class << self
        def load_form(model)
          completed_attrs(model, :upload_application_form).merge(application_form: model.application_form)
        end
      end

      private

      def application_form_presence
        return if application_form.present?

        errors.add(:application_form, :blank)
      end
    end
  end
end
