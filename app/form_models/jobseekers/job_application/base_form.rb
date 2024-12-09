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
          load_form_attributes(model.attributes)
        end

        def load_form_attributes(attrs)
          attrs.symbolize_keys.slice(*fields)
        end
      end
    end
  end
end
