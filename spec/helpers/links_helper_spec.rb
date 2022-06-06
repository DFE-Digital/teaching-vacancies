require "rails_helper"

RSpec.describe LinksHelper do
  describe "#open_in_new_tab_link_to" do
    subject { helper.open_in_new_tab_link_to(text, href, **kwargs) }

    let(:text) { "Hello world!" }
    let(:href) { "/open-me-please" }
    let(:kwargs) { { class: "special-class", data: { awesome: "true" } } }

    it "returns a link with (open in a new tab) text and correct class" do
      expect(subject).to have_link("#{text} (opens in a new tab)", href: href, class: "govuk-link special-class")
    end

    it "returns a link with correct attributes" do
      expect(subject).to match(/target="_blank"/)
      expect(subject).to match(/rel="noreferrer noopener"/)
      expect(subject).to match(/data-awesome="true"/)
    end
  end

  describe "#organisation_vacancies_link" do
    subject { helper.organisation_vacancies_link(organisation) }

    let(:organisation) { create(:school) }
    let(:link_text) { "#{URI(root_url).host}/organisations/#{organisation.slug}" }

    it "generates a link with the URL included in the link text" do
      expect(subject).to have_link("#{link_text} (opens in a new tab)", href: helper.organisation_landing_page_path(organisation))
    end
  end
end
