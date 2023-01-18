require "aws-sdk-core"

module Seahorse
  module Client
    module Plugins
      class RaiseResponseErrors < Plugin
        class Handler < Client::Handler
          def call(context)
            response = @handler.call(context)
            raise response.inspect if response.error

            response
          end
        end
      end
    end
  end
end
