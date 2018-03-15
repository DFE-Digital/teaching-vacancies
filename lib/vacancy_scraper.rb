require 'open-uri'
require 'nokogiri'

module VacancyScraper
  VERSION = '0.0.1'.freeze
end

require 'vacancy_scraper/north_east_schools'
require 'vacancy_scraper/north_east_schools/list_manager'
require 'vacancy_scraper/north_east_schools/scraper'
require 'vacancy_scraper/north_east_schools/processor'
