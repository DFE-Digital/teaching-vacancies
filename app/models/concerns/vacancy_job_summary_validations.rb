module VacancyJobSummaryValidations
  extend ActiveSupport::Concern

  included do
    validates :job_summary, presence: true
    validate :about_school_must_not_be_blank
  end

  def about_school_must_not_be_blank
    if defined?(vacancy) && vacancy.job_location == 'central_office'
      organisation = 'trust'
    else
      organisation = 'school'
    end
    errors.add(:about_school,
      I18n.t('activerecord.errors.models.vacancy.attributes.about_school.blank',
      organisation: organisation)
    ) if about_school.blank?
  end
end
