require "rails_helper"

RSpec.describe "home/index" do
  let(:organisation) { build_stubbed(:school) }

  before do
    allow(view).to receive_messages(show_cookies_banner?: false,
                                    current_organisation: organisation)
    assign :form, Jobseekers::SearchForm.new

    if jobseeker.present?
      sign_in(jobseeker, scope: :jobseeker)
    elsif publisher.present?
      sign_in(publisher, scope: :publisher)
    end

    # This syntax is required in view specs as it can't guess the layout context
    # https://groups.google.com/g/rspec/c/mek1QKvu3MQ
    render template: "home/index", layout: "layouts/application"
  end

  after do
    if jobseeker.present?
      sign_out jobseeker
    elsif publisher.present?
      sign_out publisher
    end
  end

  context "when user is not signed in" do
    let(:jobseeker) { nil }
    let(:publisher) { nil }

    it "renders the correct links" do
      expect(rendered).to have_content(I18n.t("buttons.sign_in"))
      expect(rendered).to have_content(I18n.t("buttons.search"))
      expect(rendered).to have_link(I18n.t("sub_nav.jobs"), href: jobs_path)
      expect(rendered).to have_link(I18n.t("sub_nav.schools"), href: organisations_path)
    end
  end

  context "when jobseeker is signed in" do
    let(:jobseeker) { create(:jobseeker) }
    let(:publisher) { nil }

    it "renders the correct links" do
      expect(rendered).to have_content(I18n.t("sub_nav.jobs"))
      expect(rendered).to have_content(I18n.t("sub_nav.schools"))
      expect(rendered).to have_content(I18n.t("sub_nav.jobseekers.applications"))
      expect(rendered).to have_content(I18n.t("nav.your_account"))
      expect(rendered).to have_content(I18n.t("nav.sign_out"))
    end
  end

  context "when publisher is signed in" do
    let(:jobseeker) { nil }
    let(:publisher) { create(:publisher) }

    it "renders the correct links" do
      expect(rendered).to have_content(I18n.t("nav.manage_jobs"))
      expect(rendered).to have_content(I18n.t("nav.notifications_html", count: 0))
      expect(rendered).to have_content(I18n.t("nav.sign_out"))
    end
  end
end
