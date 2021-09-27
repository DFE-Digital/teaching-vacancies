class SitemapController < ApplicationController
  include SeoHelper

  helper_method :seo_friendly_url

  def show
    secure = true
    if Rails.env.development?
      secure = false
    end
    map = XmlSitemap::Map.new(DOMAIN, secure: secure) do |m|
      add_vacancies(m)
      add_new_session(m)
      add_locations(m)
      add_subjects(m)
      add_job_roles(m)
      add_pages(m)
    end

    expires_in 3.hours
    render xml: map.render
  end

  private

  def add_vacancies(map)
    Vacancy.listed.applicable.find_each do |vacancy|
      map.add job_path(vacancy), updated: vacancy.updated_at, expires: vacancy.expires_at, period: "hourly", priority: 0.7
    end
  end

  def add_new_session(map)
    map.add new_publisher_session_path, period: "weekly", priority: 0.8
  end

  def add_locations(map)
    ALL_IMPORTED_LOCATIONS.each do |location|
      map.add seo_friendly_url(location_path(location)), period: "hourly"
    end
  end

  def add_subjects(map)
    SUBJECT_OPTIONS.map(&:first).each do |subject|
      map.add seo_friendly_url(subject_path(subject)), period: "hourly"
    end
  end

  def add_job_roles(map)
    Vacancy.job_roles.each_key do |job_role|
      map.add seo_friendly_url(job_role_path(job_role)), period: "hourly"
    end
  end

  def add_pages(map)
    map.add page_path("privacy-policy"), period: "weekly"
    map.add page_path("terms-and-conditions"), period: "weekly"
    map.add page_path("cookies"), period: "weekly"
    map.add page_path("accessibility"), period: "weekly"
  end
end
