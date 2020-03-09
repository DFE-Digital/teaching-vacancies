class SchoolVacancyPresenter < BasePresenter
  include DateHelper
  include ActionView::Helpers::UrlHelper

  def page_views
    model.total_pageviews || 0
  end

  def publish_on
    format_date(model.publish_on)
  end

  def created_at
    format_date(model.created_at)
  end

  def days_to_apply
    if model.expires_on == Time.zone.today
      return 'Deadline is today'
    elsif model.expires_on == Time.zone.tomorrow
      return 'Deadline is tomorrow'
    end
    days_left = (model.expires_on - Time.zone.today).to_i
    "#{days_left} days remaining to apply"
  end

  def expires_on
    format_date(model.expires_on)
  end

  def application_deadline
    expiry_time_formatted = model.expiry_time.nil? ? '' : I18n.t('jobs.time_at') + format_time(model.expiry_time)
    format_date(model.expires_on) + expiry_time_formatted
  end

  def preview_path
    url_helpers.school_job_path(model.id)
  end

  def edit_path
    url_helpers.edit_school_job_path(model.id)
  end

  def copy_path
    url_helpers.new_school_job_copy_path(model.id)
  end

  def delete_path
    url_helpers.school_job_path(id: model.id)
  end

  private

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
