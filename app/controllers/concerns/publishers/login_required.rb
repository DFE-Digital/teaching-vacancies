# frozen_string_literal: true

module Publishers
  module LoginRequired
    extend ActiveSupport::Concern

    included do
      include Authenticated

      self.authentication_scope = :publisher
    end
  end
end
