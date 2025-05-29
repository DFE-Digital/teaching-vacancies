require "rails_helper"

RSpec.describe "organisations/schools/index" do
  before do
    assign :organisation, organisation
    render
  end

  context "when the organisation is a school group" do
    let(:organisation) { build_stubbed(:trust, schools: [school_one, school_two]) }
    let(:school_one) { build_stubbed(:school) }
    let(:school_two) { build_stubbed(:school) }

    it "displays a list of schools associated with the school group" do
      organisation.schools.each do |school|
        expect(rendered).to have_content(school.name)
        expect(rendered).to have_link(href: organisation_path(school))
      end
    end
  end
end
