# frozen_string_literal: true

module Jobseekers
  module Profiles
    class DeleteLocationForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :action
      validates :action, inclusion: { in: %w[edit delete], message: :blank }
    end
  end
end
