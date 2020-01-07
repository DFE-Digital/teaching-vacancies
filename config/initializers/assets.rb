# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# GOV.UK Design system
# Add additional assets to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/govuk')
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/govuk/assets')
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/govuk/assets/images')
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/govuk/assets/fonts')
