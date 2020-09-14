class SitemapController < ApplicationController
  def show
    map = XmlSitemap::Map.new(DOMAIN, secure: true) do |m|
      add_vacancies(m)
      add_new_identifications(m)
      add_location_categories(m)
      add_pages(m)
    end

    expires_in 3.hours
    render xml: map.render
  end

private

  def add_vacancies(map)
    Vacancy.listed.applicable.find_each do |vacancy|
      map.add job_path(vacancy, protocol: 'https'), updated: vacancy.updated_at,
                                                    expires: vacancy.expires_on,
                                                    period: 'hourly', priority: 0.7
    end
  end

  def add_new_identifications(map)
    map.add new_identifications_path(protocol: 'https'), period: 'weekly',
                                                         priority: 0.8
  end

  def add_location_categories(map)
    ALL_LOCATION_CATEGORIES.each do |location_category|
      map.add location_category_path(location_category, protocol: 'https'), period: 'hourly'
    end
  end

  def add_pages(map)
    map.add page_path('privacy-policy', protocol: 'https'), period: 'weekly'
    map.add page_path('terms-and-conditions', protocol: 'https'), period: 'weekly'
    map.add page_path('cookies', protocol: 'https'), period: 'weekly'
    map.add page_path('accessibility', protocol: 'https'), period: 'weekly'
  end
end
