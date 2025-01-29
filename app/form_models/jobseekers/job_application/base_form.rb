module Jobseekers
  module JobApplication
    class BaseForm < ::BaseForm
      class << self
        def fields
          storable_fields + unstorable_fields
        end

        def unstorable_fields
          []
        end

        def storable_fields
          []
        end

        def load_form(model)
          model.slice(*storable_fields)
        end
      end
    end
  end
end
