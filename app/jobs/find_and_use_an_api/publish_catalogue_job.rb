module FindAndUseAnApi
  class PublishCatalogueJob < ApplicationJob
    queue_as :low

    # Deliberately not guarded by DisableIntegrations: that flag is true on staging, and staging
    # is where we publish to the FaUAPI pre-production catalogue. FauapiPublishing is the
    # per-environment switch instead, and PublishCatalogue checks it.
    def perform
      FindAndUseAnApi::PublishCatalogue.call
    end
  end
end
