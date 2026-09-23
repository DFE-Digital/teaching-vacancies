# Imports the ATS API manifest into the DfE "Find and Use an API" catalogue and publishes the
# resulting entry. Run daily by FindAndUseAnApi::PublishCatalogueJob; see
# documentation/service/integrations/find-and-use-an-api.md.
#
# The import is an upsert keyed on name + majorVersion, so republishing an unchanged manifest on
# every run is harmless.
module FindAndUseAnApi
  class PublishCatalogue
    class Error < StandardError; end

    class << self
      def call
        unless FauapiPublishing.enabled?
          Rails.logger.info("Find and Use an API: publishing is disabled, skipping")
          return
        end

        manifest = BuildManifest.call
        major_version = manifest.fetch(:majorVersion)
        Rails.logger.info("Find and Use an API: importing #{manifest.fetch(:name)} #{major_version}")

        Client.import(manifest)
        api_id = catalogue_entry_id(manifest.fetch(:name), major_version)
        Client.publish(api_id)

        Rails.logger.info("Find and Use an API: published id=#{api_id} version=#{major_version}")
      end

      private

      # More than one match means someone has created a duplicate entry by hand. Publishing a
      # guess would overwrite whichever one consumers are actually using, so stop instead.
      def catalogue_entry_id(name, major_version)
        matches = Client.list_apis.select do |api|
          api["name"] == name && api["majorVersion"] == major_version
        end

        case matches.size
        when 1
          matches.first.fetch("id")
        when 0
          raise Error, "No catalogue entry for #{name} (#{major_version}) after import"
        else
          raise Error, "Ambiguous catalogue entries for #{name} (#{major_version}): ids #{matches.pluck('id').join(', ')}"
        end
      end
    end
  end
end
