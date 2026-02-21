# frozen_string_literal: true

module Jobseekers
  module Profiles
    class SubjectsForm < ProfilesForm
      class << self
        def fields
          { subjects: [] }
        end
      end

      def params_to_save
        { subjects: subjects }
      end

      attribute :subjects, array: true

      def skip?(model)
        return false if model.key_stages.intersect?(%w[ks3 ks4 ks5])

        self.subjects = []
        true
      end
    end
  end
end
