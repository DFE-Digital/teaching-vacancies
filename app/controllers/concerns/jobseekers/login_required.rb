# frozen_string_literal: true

module Jobseekers
  module LoginRequired
    extend ActiveSupport::Concern

    included do
      include Authenticated

      self.authentication_scope = :jobseeker
    end
  end
end
