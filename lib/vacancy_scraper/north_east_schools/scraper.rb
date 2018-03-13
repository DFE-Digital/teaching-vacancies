require 'open-uri'
require 'nokogiri'

module VacancyScraper::NorthEastSchools
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
      school = School.where('levenshtein(name, ?) <= 3', school_name).first
      school = School.where('url like ?', "#{url}%").first if school.nil?
      if school.nil?
        puts "Unable to find #{school_name}"
        return
      end

      vacancy = Vacancy.new
      vacancy.job_title = job_title
      vacancy.headline = job_title
      vacancy.subject = Subject.find_by(name: subject)
      vacancy.school = school

      vacancy.job_description = body
      vacancy.working_pattern = working_pattern
      vacancy.weekly_hours = work_hours
      vacancy.minimum_salary = min_salary
      vacancy.maximum_salary = max_salary
      vacancy.expires_on = ends_on
      vacancy.status = :draft
      vacancy.publish_on = Date.today

      if vacancy.valid?
        vacancy.save
      else
        Rails.logger.debug ("Invalid vacancy: #{vacancy.errors}") unless vacancy.valid?
      end
    rescue Exception => e
      Rails.logger.debug ("Unable to save scraped vacancy: #{e.inspect}")
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
      return max_salary[1].join('') if max_salary.present?

      payscale = salary[/(UPS\d*)/, 1]
      payscale.present? ? PayScale::UPS[payscale.to_sym] : nil
    end

    def min_salary
      min_salary = salary.scan(/(\d\d+),(\d{3})/)
      return min_salary.first.join('') if min_salary.present?

      payscale = salary[/(MPS\d*)/, 1]
      return PayScale::MPS[payscale.to_sym] if payscale.present?

      payscale = salary.scan(/(L)\w*\s*(P)\w*\s*(S)\w*\s*(\d*)/)
      return PayScale::LPS[payscale.join('').to_sym] if payscale.present?

      0
    end

    def pay_scale
      payscale = salary[/(\wPS\d*)/, 1]
      return payscale if payscale.present? and (PayScale::MPS.keys.include?(payscale.to_sym) ||
                                                PayScale::UPS.keys.include?(payscale.to_sym))

      payscale = salary.scan(/(L)\w*\s*(P)\w*\s*(S)\w*\s*(\d*)/)
      return payscale.join('') if payscale.present? and PayScale::LPS.keys.include?(payscale.join('').to_sym)

      return PayScale::MPS.key(min_salary.to_i).to_s if PayScale::MPS.value?(min_salary.to_i)
      return PayScale::UPS.key(min_salary.to_i).to_s if PayScale::UPS.value?(min_salary.to_i)
      return PayScale::LPS.key(min_salary.to_i).to_s if PayScale::LPS.value?(min_salary.to_i)
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
    rescue
      nil
    end
  end
end
