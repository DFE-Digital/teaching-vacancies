require "rails_helper"

RSpec.describe "publishers/build_vacancy_templates/applying_for_the_job" do
  let(:publisher) { build_stubbed(:publisher) }
  let(:form) { Publishers::JobListing::ApplyingForTheJobForm.new }

  before do
    assign(:form, form)
    allow(view).to receive_messages(current_organisation: organisation, wizard_path: "")
    sign_in(publisher, scope: :publisher)
    render
  end

  after { sign_out publisher }

  context "with a faith school" do
    let(:organisation) { build_stubbed(:school, :catholic) }

    it "offers the religious application forms" do
      expect(rendered).to have_content("Catholic Education Service approved online application form")
      expect(rendered).to have_content("Teaching Vacancies application form with questions about religion")
    end
  end

  context "with a non-faith school" do
    let(:organisation) { build_stubbed(:school, religious_character: "None") }

    it "does not offer the religious application forms" do
      expect(rendered).to have_no_content("Catholic Education Service approved online application form")
      expect(rendered).to have_no_content("Teaching Vacancies application form with questions about religion")
    end
  end

  context "with a school group containing a faith school" do
    let(:organisation) { create(:school_group, schools: [create(:school, :catholic)]) }

    it "offers the religious application forms" do
      expect(rendered).to have_content("Catholic Education Service approved online application form")
      expect(rendered).to have_content("Teaching Vacancies application form with questions about religion")
    end
  end

  context "with a school group containing no faith schools" do
    let(:organisation) { create(:school_group, schools: [create(:school, religious_character: "None")]) }

    it "does not offer the religious application forms" do
      expect(rendered).to have_no_content("Catholic Education Service approved online application form")
      expect(rendered).to have_no_content("Teaching Vacancies application form with questions about religion")
    end
  end
end
