# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require_relative 'config/application'
Rails.application.load_tasks

desc 'Run all the specs'
task default: %i[spec teaspoon]

namespace :db do
  desc 'runs `data:seed:pay_scale` and `data:update:pay_scale`'
  task seed: %i[data:seed:pay_scale data:update:pay_scale]
end
