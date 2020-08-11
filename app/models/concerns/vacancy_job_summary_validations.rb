module VacancyJobSummaryValidations
  extend ActiveSupport::Concern

  included do
    validates :job_summary, presence: true
    validate :about_school_must_not_be_blank
  end

  def about_school_must_not_be_blank
    return if about_school.present?
    # Since vacancy is set by VacancyForm.initialize, it can be undefined here.
    if defined?(vacancy) && vacancy&.job_location == 'central_office'
      organisation = 'trust'
    elsif defined?(vacancy)
      organisation = 'school'
    else
      organisation = 'school or trust'
    end
    errors.add(:about_school,
      I18n.t('job_summary_errors.about_school.blank',
      organisation: organisation)
    )
  end
end
