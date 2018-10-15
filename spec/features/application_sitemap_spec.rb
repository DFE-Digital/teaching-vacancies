require 'rails_helper'
RSpec.feature 'Application sitemap', sitemap: true do
  context 'sitemap.xml' do
    scenario 'generates a sitemap of the application' do
      published_jobs = create_list(:vacancy, 4, :published)

      visit sitemap_path(format: :xml)
      document = Nokogiri::XML::Document.parse(body)
      nodes = document.search('url')

      expect(nodes.count).to eq(9)
      expect(nodes.search("loc[text()='#{root_url}']").text).to eq(root_url)

      published_jobs.each do |job|
        expect(nodes.search("loc:contains('#{job_url(job)}')").text).to eq(job_url(job))
      end

      expect(nodes.search("loc:contains('#{page_url('terms-and-conditions')}')").text)
        .to eq(page_url('terms-and-conditions'))
      expect(nodes.search("loc:contains('#{page_url('cookies')}')").text)
        .to eq(page_url('cookies'))
      expect(nodes.search("loc:contains('#{page_url('privacy-policy')}')").text)
        .to eq(page_url('privacy-policy'))
    end
  end
end
