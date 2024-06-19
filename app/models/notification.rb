class Notification < ApplicationRecord
  belongs_to :recipient, polymorphic: true

  validates :type, presence: true

  self.inheritance_column = nil
end
