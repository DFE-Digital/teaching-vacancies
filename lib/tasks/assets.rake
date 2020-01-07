desc 'Import GOV.UK design system assets'
namespace :assets do
  task import_from_govuk_frontend: :environment do
    source = Rails.root.join('node_modules/govuk-frontend/govuk/assets')
    destination = Rails.root.join('app/assets')
    FileUtils.copy_entry source, destination
  end
end
