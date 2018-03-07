require 'open-uri'
require 'nokogiri'

module VacancyScraper
  module NorthEastSchools
    BASE_URL = 'https://www.jobsinschoolsnortheast.com'

    class Processor
      attr_accessor :listing

      def initialize
        @listing = ListManager.new
      end

      def self.execute!
        processor = Processor.new
        listing = processor.listing
        next_page = true
        while (next_page)
          listing.search_results.each do |sr|
            Scraper.new(sr).map!
          end
          next_page = listing.next_page
          listing = next_page.present? ? ListManager.new(listing.next_page) : next_page = false
        end
      end
    end

    class ListManager
      ALTTEACHER = BASE_URL + '/search-results/?schooltype=82+96+87+84+80+74+81+73+85+76+72+75+91+83&jobrole=11&subject=&area='

      def initialize(root=ALTTEACHER)
      @root = root
        @page = Nokogiri::HTML(open(root))
      end

      def search_results
        search_box.xpath('//div[contains(@class, "media")]').xpath('//a[contains(@class,"media-content")]').map do |result|
          result.attr('href')
        end
      end

      def next_page
        paginate_next = pagination.xpath('//a[i[contains(@class, "icon-angle-right")]]')
        url = paginate_next.attr('href') rescue nil
        @next_page = url.present? ? URI.join(BASE_URL, url).to_s : nil
      end

      private
      def search_box
        @search_box = @page.xpath('//div[contains(@class, "featured-vacancies")]')
      end

      def pagination
        @pagination = search_box.xpath('//div[contains(@class, "pagination")]')
      end
    end

    class Scraper
      def initialize(url='https://www.jobsinschoolsnortheast.com/job/teacher-of-psychology-2/')
        @vacancy_url = url
      end

      def page
        @page ||= Nokogiri::HTML(open(@vacancy_url))
      end

      def map!
        v = Vacancy.new
        v.job_title = job_title
        v.headline = job_title
        v.subject = Subject.find_by_name(subject)
        v.school = School.find_by(name: school_name)
        #v.contract = contract
        v.working_pattern = working_pattern.present? && working_pattern.starts_with?(/f/i) ? :full_time : :part_time
        v.weekly_hours = work_hours
        puts min_salary
        v.minimum_salary = min_salary
        puts max_salary
        v.maximum_salary = max_salary
        puts v.error_messages unless v.valid?
        v.save
      rescue Exception => e
        puts "Unable to save vacancy"
        puts e.inspect
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
        !pattern.nil? ? pattern[/(full.time|part.time)/i,1] : nil
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
end
