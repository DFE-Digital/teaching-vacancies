# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

# GOV.UK Design system
# Add additional assets to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('../../usr/local/bin/govuk_design_system/node_modules')
Rails.application.config.assets.precompile += %w[govuk-frontend/all.js]

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile +=
  %w[application.css application-ie8.css application.js]
