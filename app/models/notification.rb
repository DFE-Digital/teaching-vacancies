class Notification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true

  scope :created_within_data_access_period, (-> { where("created_at >= ?", Time.current - DATA_ACCESS_PERIOD_FOR_PUBLISHERS) })
end
