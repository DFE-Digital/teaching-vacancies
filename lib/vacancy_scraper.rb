require 'open-uri'
require 'nokogiri'

module VacancyScraper
  class NorthEastSchools

    def initialize(url="https://www.jobsinschoolsnortheast.com/job/teacher-of-psychology-2/")
      @vacancy_url = url
    end

    def page
      @page ||= Nokogiri::HTML(open(@vacancy_url))
    end

    def vacancy
      @vacancy ||= page.css('article.featured-vacancies').first
    end

    def job_title
      vacancy.css('.page-title').text
    end

    def subject
      subjects = Subject.pluck(:name).join("|")
      job_title[/(#{subjects})/, 1]
    end

    def school_name
      vacancy.xpath('//li[strong[contains(text(), "School:")]]').children.last.text.strip
    end

    def contract
      vacancy.at("li:contains('Contractual Status:')").text
      vacancy.xpath('//li[strong[contains(text(), "Contractual Status:")]]').text

      vacancy.xpath('//li[strong[contains(text(), "Contractual Status:")]]').children.last.text.strip
    end

    def working_pattern
      pattern = vacancy.xpath('//li[strong[contains(text(), "Hours:")]]').children.last.text.strip
      pattern[/(full.time|part.time)/i,1]
    end

    def work_hours
      pattern = vacancy.xpath('//li[strong[contains(text(), "Hours:")]]').children.last.text.strip
      pattern[/(\d*.\d*)/,1]
    end

    def salary
      @salary ||= vacancy.xpath('//li[strong[contains(text(), "Salary:")]]').children.last.text.strip
    end

    def max_salary
      max_salary = salary.scan(/\d*.?(\d\d+,\d{3})/)
      max_salary.empty? ? nil : max_salary[1][0]
    end

    def min_salary
      salary[/(\d\d+.?\d{3})/,1]
    end

    def pay_scale
      salary[/(\w)PS/,1]
    end

    def leadership
    end

    def benefits
    end

    def starts_on
    end

    def ends_on
      page.xpath('//p[strong[contains(text(), "Closing date:")]]').children.last.text.strip
    end
  end
end
