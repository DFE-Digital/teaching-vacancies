require "rails_helper"

RSpec.describe LinksHelper do
  describe "#open_in_new_tab_link_to" do
    subject { helper.open_in_new_tab_link_to(text, href, **kwargs) }

    let(:text) { "Hello world!" }
    let(:href) { "/open-me-please" }
    let(:kwargs) { { class: "special-class", data: { awesome: "true" } } }

    it "returns a link with (open in a new tab) text and correct class" do
      expect(subject).to have_link("#{text} (opens in new tab)", href: href, class: "govuk-link special-class")
    end

    it "returns a link with correct attributes" do
      expect(subject).to match(/target="_blank"/)
      expect(subject).to match(/rel="noreferrer noopener"/)
      expect(subject).to match(/data-awesome="true"/)
    end
  end

  describe "#external_advert_link" do
    subject { helper.external_advert_link(vacancy) }

    let(:vacancy) { build_stubbed(:vacancy, :external) }

    it "links through the apply action" do
      expect(subject).to have_link(href: helper.apply_job_path(vacancy))
    end

    it "tracks the external advert URL as the link destination" do
      expect(subject).to have_css("a[data-tracked-link-href='#{vacancy.external_advert_url}']")
    end

    it "sends our origin as the referrer so the destination can attribute the traffic" do
      expect(subject).to have_css("a[rel='noopener']")
    end
  end

  describe "#apply_link" do
    subject { helper.apply_link(vacancy) }

    let(:vacancy) { build_stubbed(:vacancy, :apply_via_website) }

    it "links through the apply action" do
      expect(subject).to have_link(href: helper.apply_job_path(vacancy))
    end

    it "tracks the application link as the link destination" do
      expect(subject).to have_css("a[data-tracked-link-href='#{vacancy.application_link}']")
    end

    it "sends our origin as the referrer so the destination can attribute the traffic" do
      expect(subject).to have_css("a[rel='noopener']")
    end
  end

  describe "#organisation_vacancies_link" do
    subject { helper.organisation_vacancies_link(organisation) }

    let(:organisation) { create(:school) }
    let(:link_text) { "#{URI(root_url).host}/organisations/#{organisation.slug}" }

    it "generates a link with the URL included in the link text" do
      expect(subject).to have_link(link_text.to_s, href: helper.organisation_landing_page_path(organisation))
    end
  end
end
