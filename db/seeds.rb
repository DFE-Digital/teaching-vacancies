raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

FactoryBot.create(:vacancy, :published, :at_one_school)
