class SitemapController < ApplicationController
  def show
    map = XmlSitemap::Map.new(DOMAIN, secure: !Rails.env.development?) do |m|
      add_vacancies(m)
      add_locations(m)
      add_subjects(m)
      add_job_roles(m)
      add_education_phases(m)
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

  def add_locations(map)
    ALL_IMPORTED_LOCATIONS.each do |location|
      map.add location_path(location.parameterize), period: "hourly"
    end
  end

  def add_subjects(map)
    SUBJECT_OPTIONS.map(&:first).each do |subject|
      map.add subject_path(subject.parameterize), period: "hourly"
    end
  end

  def add_job_roles(map)
    Vacancy.job_roles.each_key do |job_role|
      map.add job_role_path(job_role.dasherize), period: "hourly"
    end
  end

  def add_education_phases(map)
    School.available_readable_phases.each do |phase|
      map.add education_phase_path(phase.dasherize), period: "hourly"
    end
  end

  def add_pages(map)
    map.add page_path("privacy-policy"), period: "weekly"
    map.add page_path("terms-and-conditions"), period: "weekly"
    map.add page_path("cookies"), period: "weekly"
    map.add page_path("accessibility"), period: "weekly"
  end
end
