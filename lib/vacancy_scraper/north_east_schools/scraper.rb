require 'open-uri'
require 'nokogiri'

module VacancyScraper::NorthEastSchools
  class Scraper
    include ActionView::Helpers::SanitizeHelper

    SUBJECTS_REGEX = 'Chemistry|Economics|General Science|History|Maths|Other|Primary|' \
                      'Spanish|Art|Classics|English Language|Geography|ICT|Media Studies|' \
                      'Physical Education|Psychology|Statistics|Biology|Design Technology|' \
                      'English Literature|German|Latin|Music|Physics|Religious Studies|' \
                      'Business Studies|Drama|French|Health and Social care|Law|Politics|Sociology'.freeze

    def initialize(url)
      @vacancy_url = url
    end

    def page
      @page ||= Nokogiri::HTML(open(@vacancy_url))
      @page.search('br').each { |br| br.replace('\n') }
      @page
    end

    # rubocop:disable Metrics/AbcSize
    def map!
      return if vacancy_scraped?
      return Rails.logger.debug("Unable to find school: #{school_name}") if school.nil?

      vacancy = Vacancy.new
      vacancy.job_title = job_title
      vacancy.subject = Subject.find_by(name: subject)
      vacancy.school = school
      vacancy.job_description = job_description
      vacancy.working_pattern = working_pattern
      vacancy.weekly_hours = work_hours
      vacancy.minimum_salary = min_salary
      vacancy.maximum_salary = max_salary
      vacancy.pay_scale = PayScale.where(code: pay_scale).first
      vacancy.starts_on = starts_on
      vacancy.expires_on = ends_on
      vacancy.status = min_salary.to_i.positive? ? :published : :draft
      vacancy.publish_on = Time.zone.today
      vacancy.application_link = application_link
      vacancy.send :set_slug

      return vacancy.save(validate: false) if valid?(vacancy)
      vacancy.valid?
      Rails.logger.debug("Invalid vacancy: #{vacancy.errors.inspect}")
    rescue StandardError => e
      Rails.logger.debug("Unable to save scraped vacancy: #{e.inspect}")
    end
    # rubocop:enable Metrics/AbcSize

    def school
      @school ||= begin
        school_matches = School.where('levenshtein(name, ?) <= 1 or url like ?', school_name, "#{url}%")

        if school_matches.count > 1
          Rails.logger.debug('Matched on multiple schools so could not safely determine the correct school' \
                             "based on: #{school_name}. It matched: #{school_matches.map(&:name).join(', ')}" \
                             "which have the following school URN: #{school_matches.map(&:urn).join(', ')}")
          return nil
        end

        school_matches.first
      end
    end

    def application_link
      "#{@vacancy_url}#application"
    end

    def vacancy
      @vacancy ||= page.css('article.featured-vacancies').first
    end

    def job_title
      vacancy.css('.page-title').text
    end

    def job_description
      sanitize(body.to_html)
    end

    def subject
      job_title[/(#{SUBJECTS_REGEX})/, 1]
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
      working_pattern = pattern.scan(/(full|part).(time)/i).join('_').downcase
      working_pattern.empty? ? :full_time : working_pattern.to_sym
    end

    def work_hours
      hours_string = vacancy.xpath('//li[strong[contains(text(), "Hours:")]]')
      hours_string.children.any? ? hours_string.children.last.text[/(\d+.\d+)/, 1] : nil
    end

    def salary
      @salary ||= vacancy.xpath('//li[strong[contains(text(), "Salary:")]]').children.last.text.strip
    end

    # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    def max_salary
      max_salary = salary.scan(/\d*.?(\d\d+),(\d{3})/)
      return max_salary[1].join('') if max_salary.present?

      code = salary[/(UP[SR]\d*)/, 1] || salary[/(Upper).*[Ss]cale/, 1] || salary[/(U\d{1})/, 1]
      code = 'UPS3' if ['UPS', 'UPR', 'Upper'].include?(code)
      code = code.present? ? code.gsub(/(\w{1,3})(\d)/, 'UPS\2') : nil

      pay_scale = PayScale.find_by(code: code)
      return pay_scale.salary if pay_scale.present?

      code = salary.scan(/Leader[\W\w]*(L)\d+\W+(\d+)/).join('')
      code = salary[/L\d+\W+(L\d+)/, 1] if code.empty?
      code = code.present? ? code.gsub(/(L)(\d+)/, 'LPS\2') : nil
      pay_scale = PayScale.find_by(code: code) if code.present?

      pay_scale.present? ? pay_scale.salary : nil
    end
    # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity

    # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    def min_salary
      min_salary = salary.scan(/(\d\d+),(\d{3})/)
      return min_salary.first.join('') if min_salary.present?

      code = salary[/(MP[SR]\d*)/, 1] || salary[/(Main).*[Ss]cale/, 1] || salary[/(M\d{1})/, 1]

      code = 'MPS1' if ['M1', 'MPS', 'MPR', 'Main'].include?(code)
      code = code.present? ? code.gsub(/(\w{1,3})(\d)/, 'MPS\2') : nil

      payscale = code.present? ? PayScale.find_by(code: code) : nil
      return payscale.salary if payscale.present?

      code = salary.scan(/(L)\w*\s*(P)\w*\s*(S)\w*\s*(\d*)/)
      payscale = PayScale.find_by(code: code.join('')) if code.present?

      return payscale.salary if payscale.present?

      code = salary.scan(/Leader[\W\w]*(L)(\d+)\W+\d+/).join('')
      code = salary[/(L\d+)\W+L\d+/, 1] if code.empty?
      code = code.present? ? code.gsub(/(L)(\d+)/, 'LPS\2') : nil

      payscale = PayScale.find_by(code: code) if code.present?
      return payscale.salary if payscale.present?

      payscale.present? ? payscale.salary : 0
    end
    # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity

    # # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
    def pay_scale
      payscale_pattern = salary[/(\wPS\d*)/, 1] || salary[/([MU]\d+)/, 1]
      payscale = payscale_pattern.present? ? payscale_pattern.gsub(/\W*(\w{1})(\d+)/, '\1PS\3') : nil
      payscale = 'MPS1' if payscale == 'MPS'
      payscale = 'UPS3' if payscale == 'UPS'
      return payscale if payscale.present? && PayScale.exists?(code: payscale)

      payscale = salary.scan(/(L)\w*\s*(P)\w*\s*(S)\w*\s*(\d*)/)
      return payscale.join('') if payscale.present? && PayScale.exists?(code: payscale)

      pay_scale = PayScale.find_by(salary: min_salary)
      pay_scale.present? ? pay_scale.code : nil
    end
    # rubocop:enable

    def leadership; end

    def benefits; end

    def body
      xpath = '//div[@class="job-list-mobile"]/following-sibling::*[not(self::div[@id="schoolinfo"])' \
        'and not(self::div[@id="apply"]) and not(self::div[@class="supporting-documents"])]'
      @body ||= vacancy.xpath(xpath)
      remove_blank_paragraphs
      @body
    end

    def starts_on
      starts_on_string = vacancy.xpath('//*[text()[contains(.,"Required for") or' \
                                       ' contains(.,"Start Date") or contains(.,"start in")]]').text
      starts_on = starts_on_string[/(\w+ \d{4})/, 1]
      Date.parse(starts_on)
    rescue
      nil
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

    private

    def remove_blank_paragraphs
      nodes = @body.xpath('//p').select { |n| n.text.blank? }
      nodes.each { |n| @body.delete(n) }
    end

    def valid?(vacancy)
      vacancy.job_description.present? && vacancy.job_title.present? &&
        vacancy.working_pattern.present? && vacancy.expires_on.present? &&
        vacancy.expires_on > vacancy.publish_on
    end

    def vacancy_scraped?
      Vacancy.where('application_link like ?', "#{@vacancy_url}%").exists?
    end
  end
end
