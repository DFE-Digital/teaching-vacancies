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
      return Rails.logger.debug("Unable to find school: #{school_name}") if school.nil?

      vacancy = Vacancy.new
      vacancy.job_title = job_title
      vacancy.headline = job_title
      vacancy.subject = Subject.find_by(name: subject)
      vacancy.school = school

      vacancy.job_description = Nokogiri::HTML(body).text
      vacancy.working_pattern = working_pattern
      vacancy.weekly_hours = work_hours
      vacancy.minimum_salary = min_salary
      vacancy.maximum_salary = max_salary
      vacancy.pay_scale = PayScale.where(code: pay_scale).first
      vacancy.expires_on = ends_on
      vacancy.status = min_salary.to_i.positive? ? :published : :draft
      vacancy.publish_on = Time.zone.today

      return vacancy.save if vacancy.valid?
      Rails.logger.debug("Invalid vacancy: #{vacancy.errors.inspect}")
    rescue StandardError => e
      Rails.logger.debug("Unable to save scraped vacancy: #{e.inspect}")
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

      code = salary[/(UPS\d*)/, 1]
      code = 'UPS3' if code == 'UPS'
      pay_scale = PayScale.find_by(code: code)
      pay_scale.present? ? pay_scale.salary : nil
    end

    def min_salary
      min_salary = salary.scan(/(\d\d+),(\d{3})/)
      return min_salary.first.join('') if min_salary.present?

      code = salary[/(MPS\d*)/, 1]
      code = 'MPS1' if code == 'MPS'
      payscale = PayScale.find_by(code: code)

      return payscale.salary if payscale.present?

      code = salary.scan(/(L)\w*\s*(P)\w*\s*(S)\w*\s*(\d*)/)
      payscale = PayScale.find_by(code: code.join("")) if code.present?

      payscale.present? ?  payscale.salary : 0
    end

    def pay_scale
      payscale = salary[/(\wPS\d*)/, 1]
      payscale = 'MPS1' if payscale == 'MPS'
      payscale = 'UPS3' if payscale == 'UPS'
      return payscale if payscale.present? && PayScale.exists?(code: payscale)

      payscale = salary.scan(/(L)\w*\s*(P)\w*\s*(S)\w*\s*(\d*)/)
      return payscale.join('') if payscale.present? && PayScale.exists?(code: payscale)

      pay_scale = PayScale.find_by(salary: min_salary)
      pay_scale.present? ? pay_scale.code : nil
    end

    def leadership; end

    def benefits; end

    def starts_on; end

    def body
      xpath = '//div[@class="job-list-mobile"]/following-sibling::*[not(self::div[@id="schoolinfo"])' \
        'and not(self::div[@id="apply"]) and not(self::div[@class="supporting-documents"])]'
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
