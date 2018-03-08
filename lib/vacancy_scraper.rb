require 'open-uri'
require 'nokogiri'

module VacancyScraper
  module NorthEastSchools
    BASE_URL = 'https://www.jobsinschoolsnortheast.com'.freeze
    SUBJECTS = Subject.pluck(:name).join('|')

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
            puts "Scraping #{url}"
            Scraper.new(url).map!
          end
          next_page = vacancies.next_page
          vacancies = next_page.present? ? ListManager.new(vacancies.next_page) : next_page = false
        end
      end
    end

    class ListManager
      ALTTEACHER = BASE_URL +
        '/search-results/?schooltype=82+96+87+84+80+74+81+73+85+76+72+75+91+83&jobrole=11&subject=&area='

      def initialize(root = ALTTEACHER)
        @root = root
        @page = Nokogiri::HTML(open(root))
      end

      def search_results
        search_box.xpath('//div[contains(@class, "media")]')
                  .xpath('//a[contains(@class,"media-content")]').map do |result|
          result.attr('href')
        end
      end

      def next_page
        paginate_next = pagination.xpath('//a[i[contains(@class, "icon-angle-right")]]')
        @next_page = paginate_next.present? ? URI.join(BASE_URL, paginate_next.attr('href')).to_s : nil
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
      def initialize(url = 'https://www.jobsinschoolsnortheast.com/job/teacher-of-psychology-2/')
        @vacancy_url = url
      end

      def page
        @page ||= Nokogiri::HTML(open(@vacancy_url))
        @page.search('br').each { |br| br.replace('\n') }
        @page
      end

      def map!
        v = Vacancy.new
        v.job_title = job_title
        v.headline = job_title
        v.subject = Subject.find_by_name(subject)
        school = School.where('levenshtein(name, ?) <= 3', school_name).first
        school = School.where('url like ?', "#{url}%").first if school.nil?
        v.school = school

        # v.contract = contract
        v.job_description = body
        v.working_pattern = working_pattern
        v.weekly_hours = work_hours
        v.minimum_salary = min_salary
        v.maximum_salary = max_salary
        v.expires_on = ends_on
        v.status = :draft
        #v.status = min_salary == 0 ? :draft : :published
        v.publish_on = Date.today
        puts v.errors.inspect unless v.valid?
        v.save
      rescue Exception => e
        puts 'Unable to save vacancy'
        puts e.inspect
      end

      def vacancy
        @vacancy ||= page.css('article.featured-vacancies').first
      end

      def job_title
        vacancy.css('.page-title').text
      end

      def subject
        subjects = Subject.pluck(:name).join('|')
        job_title[/(#{subjects})/, 1]
      end

      def school_name
        name = vacancy.xpath('//li[strong[contains(text(), "School:")]]').children.last.text.strip
        name.tr("'", '%')
      end

      def contract
        vacancy.xpath('//li[strong[contains(text(), "Contractual Status:")]]').children.last.text.strip
      end

      def working_pattern
        pattern = vacancy.xpath('//li[strong[contains(text(), "Hours:")]]').children.last.text.strip
        working_pattern = pattern[/(full.time|part.time)/i, 1]
        working_pattern.downcase.starts_with?('f') ? :full_time : :part_time
      rescue
        :full_time
      end

      def work_hours
        pattern = vacancy.xpath('//li[strong[contains(text(), "Hours:")]]').children.last.text.strip
        pattern[/(\d+.\d+)/, 1]
      rescue
        nil
      end

      def salary
        @salary ||= vacancy.xpath('//li[strong[contains(text(), "Salary:")]]').children.last.text.strip
      end

      def max_salary
        max_salary = salary.scan(/\d*.?(\d\d+),(\d{3})/)
        return max_salary[1].join("") if max_salary.present?

        payscale = salary[/(UPS\d*)/, 1]
        payscale.present? ? PayScale::UPS[payscale.to_sym] : nil
      end

      def min_salary
        min_salary = salary.scan(/(\d\d+),(\d{3})/)
        return min_salary.first.join("") if min_salary.present?

        payscale = salary[/(MPS\d*)/, 1]
        return PayScale::MPS[payscale.to_sym] if payscale.present?

        payscale = salary.scan(/(L)\w*\s*(P)\w*\s*(S)\w*\s*(\d*)/)
        return PayScale::LPS[payscale.join("").to_sym] if payscale.present?

        0
      end

      def pay_scale
        payscale = salary[/(MPS\d*)/, 1]
        return payscale if payscale.present? and PayScale::MPS.keys.include?(payscale.to_sym)

        payscale = salary[/(UPS\d*)/, 1]
        return payscale if payscale.present? and PayScale::UPS.keys.include?(payscale.to_sym)

        payscale = salary.scan(/(L)\w*\s*(P)\w*\s*(S)\w*\s*(\d*)/)
        return payscale.join("") if payscale.present? and PayScale::LPS.keys.include?(payscale.join("").to_sym)

        return PayScale::MPS.key(min_salary.to_i).to_s if PayScale::MPS.has_value? min_salary.to_i
        return PayScale::UPS.key(min_salary.to_i).to_s if PayScale::UPS.has_value? min_salary.to_i
        return PayScale::LPS.key(min_salary.to_i).to_s if PayScale::LPS.has_value? min_salary.to_i
        nil

      end

      def leadership; end

      def benefits; end

      def starts_on; end

      def body
        xpath = '//div[@class="job-list-mobile"]/following-sibling::*[not(self::div[@id="schoolinfo"]) and not(self::div[@id="apply"]) and not(self::div[@class="supporting-documents"])]'
        @body ||= vacancy.xpath(xpath).to_html
      end

      def supporting_documents
        vacancy.xpath('//div[@class="supporting-documents"]/a').map do |node|
          node.attr('href')
        end
      end

      def apply_link
        vacancy.css('.btn-application').attr('href')
      end

      def application_form
        vacancy.css('.btn-application').attr('href').text
      end

      def url
        page.xpath('//a[contains(text(), "Visit School Website")]').attr('href').text
      end

      def ends_on
        ends_on_string = vacancy.xpath('//*[text()[contains(.,"losing")]]').text
        ends_on_string = vacancy.xpath('//*[contains(text(),"pplication")]').text if ends_on_string.blank?
        date_parts = ends_on_string.scan(/(\d{1,2})\w*[\s](\w*)\s(\d{4})/)
        date = date_parts.is_a?(Array) ? date_parts.first.join(' ') : nil
        date.present? ? Date.parse(date) : date
      rescue Exception => e
        nil
      end
    end
  end
end
