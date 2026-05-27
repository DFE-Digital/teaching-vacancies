class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_validation :strip_attributes

  private

  def strip_attributes
    attributes.each_value { |value| value.try(:strip!) unless value.frozen? }
  end
end
