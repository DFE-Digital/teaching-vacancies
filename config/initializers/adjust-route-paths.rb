module ActionDispatch
  module Routing
    class Mapper
      module Resources
        class Resource
          def path
            # binding.pry
            @path.dasherize
          end
        end
      end
    end
  end
end
