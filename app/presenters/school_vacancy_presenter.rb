class SchoolVacancyPresenter < BasePresenter
  include DateHelper
  include ActionView::Helpers::UrlHelper

  def page_views
    model.total_pageviews || 0
  end

  # rubocop:disable Naming/AccessorMethodName
  def get_more_info_clicks
    model.total_get_more_info_clicks || 0
  end
  # rubocop:enable Naming/AccessorMethodName

  def publish_on
    format_date(model.publish_on)
  end

  def created_at
    format_date(model.created_at)
  end

  def expires_on
    format_date(model.expires_on)
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