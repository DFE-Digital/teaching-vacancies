class OrganisationVacancyPresenter < BasePresenter
  include DatesHelper
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
    case model.expires_on
    when Date.current
      I18n.t("jobs.days_to_apply.today")
    when Time.zone.tomorrow
      I18n.t("jobs.days_to_apply.tomorrow")
    else
      days_remaining = (model.expires_on - Date.current).to_i
      I18n.t("jobs.days_to_apply.remaining", days_remaining: days_remaining)
    end
  end

  def expires_on
    format_date(model.expires_on)
  end

  def application_deadline
    expires_at_formatted = model.expires_at.nil? ? "" : I18n.t("jobs.time_at") + format_time(model.expires_at)
    format_date(model.expires_on) + expires_at_formatted
  end

  def preview_path
    url_helpers.organisation_job_path(model.id)
  end

  def edit_path
    url_helpers.edit_organisation_job_path(model.id)
  end

  def copy_path
    url_helpers.new_organisation_job_copy_path(model.id)
  end

  def delete_path
    url_helpers.organisation_job_path(id: model.id)
  end

private

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
