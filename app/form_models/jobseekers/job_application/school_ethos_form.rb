# frozen_string_literal: true

class Jobseekers::JobApplication::SchoolEthosForm < Jobseekers::JobApplication::BaseForm
  def self.fields
    %i[ethos_and_aims]
  end
  attr_accessor(*fields)

  validates_presence_of :ethos_and_aims
end
