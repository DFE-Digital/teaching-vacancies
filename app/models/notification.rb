class Notification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true

  paginates_per 30

  scope :created_within_data_retention_period, (-> { where("created_at >= ?", Time.current - DATA_RETENTION_PERIOD_FOR_PUBLISHERS) })
end
