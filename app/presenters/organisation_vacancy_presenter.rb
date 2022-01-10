class OrganisationVacancyPresenter < BasePresenter
  include DatesHelper
  include ActionView::Helpers::UrlHelper

  def publish_on
    format_date(model.publish_on)
  end

  def created_at
    format_date(model.created_at)
  end

  def days_to_apply
    case model.expires_at.to_date
    when Date.current
      I18n.t("jobs.days_to_apply.today")
    when 1.day.from_now.to_date
      I18n.t("jobs.days_to_apply.tomorrow")
    else
      days_remaining = (model.expires_at.to_date - Date.current).to_i
      I18n.t("jobs.days_to_apply.remaining", days_remaining:)
    end
  end

  def application_deadline
    format_time_to_datetime_at(model.expires_at)
  end

  def preview_path
    url_helpers.organisation_job_path(model.id)
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
