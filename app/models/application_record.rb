class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_save :strip_attributes

  DATA_ACCESS_PERIOD_FOR_PUBLISHERS = 1.year.freeze

  private

  def strip_attributes
    attributes.each_value { |value| value.try(:strip!) unless value.frozen? }
  end
end
