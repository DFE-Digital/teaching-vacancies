# frozen_string_literal: true

module Jobseekers
  module Profiles
    class ProfilesForm < ::BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      def skip?(_model)
        false
      end
    end
  end
end
