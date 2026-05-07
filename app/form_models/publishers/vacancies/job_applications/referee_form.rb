# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class RefereeForm
        include ActiveModel::Model
        include ActiveModel::Validations
        include ActiveModel::Attributes

        attribute :name, :string
        attribute :uploaded_details, :boolean
        attribute :job_title, :string
        attribute :organisation, :string
        attribute :relationship, :string
        attribute :email, :string
        attribute :phone_number, :string

        validates :name, presence: true
        validates :job_title, :organisation, :relationship, presence: true, unless: -> { uploaded_details }
        validates :email, presence: true, email_address: true, unless: -> { uploaded_details }

        attr_accessor :reference_document

        validates :reference_document, presence: true, form_file: Vacancy::DOCUMENT_VALIDATION_OPTIONS, if: -> { uploaded_details }

        class << self
          def fields
            %i[name uploaded_details job_title organisation relationship email phone_number reference_document]
          end
        end
      end
    end
  end
end
