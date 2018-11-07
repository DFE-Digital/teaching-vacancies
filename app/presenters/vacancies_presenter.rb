class VacanciesPresenter < BasePresenter
  include ActionView::Helpers::UrlHelper
  attr_reader :decorated_collection, :searched

  CSV_ATTRIBUTES = %w[title description jobBenefits datePosted educationRequirements qualifications
                      experienceRequirements employmentType jobLocation.addressLocality
                      jobLocation.addressRegion jobLocation.streetAddress jobLocation.postalCode url
                      baseSalary.currency baseSalary.minValue baseSalary.maxValue baseSalary.unitText
                      hiringOrganization.type hiringOrganization.name hiringOrganization.identifier].freeze

  def initialize(vacancies, searched:)
    @decorated_collection = vacancies.map { |v| VacancyPresenter.new(v) }
    @searched = searched
    super(vacancies)
  end

  def each(&block)
    decorated_collection.each(&block)
  end

  def total_count_message
    if total_count == 1
      return I18n.t('jobs.job_count_without_search', count: total_count) unless @searched
      I18n.t('jobs.job_count', count: total_count)
    else
      return I18n.t('jobs.job_count_plural_without_search', count: total_count) unless @searched
      I18n.t('jobs.job_count_plural', count: total_count)
    end
  end

  def apply_filters_button_text
    if @searched == true
      I18n.t('buttons.apply_filters_if_criteria')
    else
      I18n.t('buttons.apply_filters')
    end
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << CSV_ATTRIBUTES
      @decorated_collection.map { |vacancy| csv << to_csv_row(vacancy) }
    end
  end

  private

  def total_count
    model.total_count
  end

  # rubocop:disable Metrics/AbcSize
  def to_csv_row(vacancy)
    [vacancy.job_title,
     vacancy.job_description,
     vacancy.benefits,
     vacancy.publish_on.to_time.iso8601,
     vacancy.education,
     vacancy.qualifications,
     vacancy.experience,
     vacancy.working_pattern_for_job_schema,
     vacancy.school.town,
     vacancy.school&.region&.name,
     vacancy.school.address,
     vacancy.school.postcode,
     Rails.application.routes.url_helpers.job_url(vacancy, protocol: 'https'),
     'GBP', vacancy.minimum_salary,
     vacancy.maximum_salary,
     'YEAR',
     'School',
     vacancy.school.name,
     vacancy.school.urn]
  end
  # rubocop:enable Metrics/AbcSize
end
