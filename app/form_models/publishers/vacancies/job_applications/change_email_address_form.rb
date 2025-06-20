# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ChangeEmailAddressForm
        include ActiveModel::Model
        include ActiveModel::Validations
        include ActiveModel::Attributes

        attribute :email, :string
        validates :email, email_address: true, presence: true

        class << self
          def fields
            [:email]
          end
        end
      end
    end
  end
end
