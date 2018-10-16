class SitemapController < ApplicationController
  def show
    map = XmlSitemap::Map.new(DOMAIN) do |m|
      Vacancy.listed.applicable.find_each do |vacancy|
        m.add job_path(vacancy, protocol: 'https'), updated: vacancy.updated_at,
                                                    expires: vacancy.expires_on,
                                                    period: 'hourly', priority: 0.7
      end

      m.add new_identifications_path(protocol: 'https'), period: 'weekly',
                                                         priority: 0.8

      m.add page_path('privacy-policy', protocol: 'https'), period: 'weekly'
      m.add page_path('terms-and-conditions', protocol: 'https'), period: 'weekly'
      m.add page_path('cookies', protocol: 'https'), period: 'weekly'
    end

    expires_in 3.hours
    render xml: map.render
  end
end
