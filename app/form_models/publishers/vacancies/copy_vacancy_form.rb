# frozen_string_literal: true

module Publishers
  module Vacancies
    class CopyVacancyForm
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes

      attribute :name, :string

      validates :name, presence: true
    end
  end
end
