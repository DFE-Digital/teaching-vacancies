require 'rails_helper'
RSpec.describe 'Application sitemap', sitemap: true do
  context 'sitemap.xml' do
    scenario 'generates a sitemap of the application' do
      published_jobs = create_list(:vacancy, 4, :published)
      build_list(:vacancy, 2, :expired).each { |j| j.save(validate: false) }
      stub_const('DOMAIN', 'localhost:3000')

      visit sitemap_path(format: :xml)
      document = Nokogiri::XML::Document.parse(body)
      nodes = document.search('url')

      expect(nodes.count).to eq(231)
      expect(nodes.search("loc[text()='#{root_url(protocol: 'https')}']").text)
        .to eq(root_url(protocol: 'https'))

      published_jobs.each do |job|
        expect(nodes.search("loc:contains('#{job_path(job, protocol: 'https')}')").text)
          .to eq(job_url(job, protocol: 'https'))
      end

      ALL_LOCATION_CATEGORIES.each do |location_category|
        url = jobs_url(location: location_category, protocol: 'https')
        expect(nodes.search("loc:contains('#{url}')").map(&:text)).to include(url)
      end

      expect(nodes.search("loc:contains('#{page_url('terms-and-conditions', protocol: 'https')}')").text)
        .to eq(page_url('terms-and-conditions', protocol: 'https'))
      expect(nodes.search("loc:contains('#{page_url('cookies', protocol: 'https')}')").text)
        .to eq(page_url('cookies', protocol: 'https'))
      expect(nodes.search("loc:contains('#{page_url('privacy-policy', protocol: 'https')}')").text)
        .to eq(page_url('privacy-policy', protocol: 'https'))
      expect(nodes.search("loc:contains('#{page_url('accessibility', protocol: 'https')}')").text)
        .to eq(page_url('accessibility', protocol: 'https'))
    end
  end
end
