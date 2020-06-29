module VacancyCopyValidations
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    validates :job_title, presence: true
    validates :job_title, length: { minimum: 4, maximum: 100 }, if: :job_title?
    validate :job_title_has_no_tags?, if: :job_title?

    validates :about_school, presence: true

    validate :publish_on_must_not_be_before_today
  end

  def job_title_has_no_tags?
    errors.add(
      :job_title, I18n.t('activemodel.errors.models.job_specification_form.attributes.job_title.invalid_characters')
    ) unless job_title == sanitize(job_title, tags: [])
  end

  def publish_on_must_not_be_before_today
    errors.add(:publish_on, I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.before_today')) if
      publish_on && publish_on < Time.zone.today
  end
end
