module VacancyScraper::NorthEastSchools
  class Processor
    attr_accessor :listing

    def initialize
      @listing = ListManager.new
    end

    def self.execute!
      vacancies = Processor.new.listing
      next_page = true
      while next_page
        vacancies.search_results.each do |url|
          Rails.logger.info("Scraping #{url}")
          Scraper.new(url).map!
        end
        next_page = vacancies.next_page
        vacancies = next_page.present? ? ListManager.new(vacancies.next_page) : next_page = false
      end
    end
  end
end
