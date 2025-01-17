# frozen_string_literal: true

class Jobseekers::JobApplication::SchoolEthosForm < Jobseekers::JobApplication::BaseForm
  FIELDS = %i[ethos_and_aims].freeze

  class << self
    def storable_fields
      FIELDS
    end
  end
  attr_accessor(*FIELDS)

  validates_presence_of :ethos_and_aims
end
