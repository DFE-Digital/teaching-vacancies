class ImportVacanciesFromFeedsJob < ApplicationJob
  FEEDS = [SkywalkerFeed].freeze

  queue_as :default

  def perform
    FEEDS.each do |feed_klass|
      feed_klass.new.each do |vacancy|
        # TODO: Basic validation would happen here
        if vacancy.save
          Rails.logger.info("Imported vacancy #{vacancy.id} from feed #{feed_klass.name}")
        else
            Rails.logger.error("Failed to save imported vacancy: #{vacancy.errors.inspect}")
        end
      end
    end
  end
end
