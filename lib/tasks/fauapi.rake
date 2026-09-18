namespace :fauapi do
  desc "Publish the ATS API OpenAPI document to the DfE Find and Use an API catalogue"
  task publish: :environment do
    FindAndUseAnApi::PublishCatalogue.call
  end

  desc "Print the Find and Use an API manifest, for validating against the FaUAPI schema"
  task manifest: :environment do
    puts JSON.pretty_generate(FindAndUseAnApi::BuildManifest.call)
  end
end
