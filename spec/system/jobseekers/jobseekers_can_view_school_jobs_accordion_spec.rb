require "rails_helper"

RSpec.describe "Jobseeker views the 'School jobs by role, phase and subject' accordion" do
  before { visit root_path }

  describe "accordion section heading" do
    it "displays the updated heading" do
      expect(page).to have_text("School jobs by role, phase and subject")
    end
  end

  describe "teaching and leadership roles" do
    it "includes a 'Teacher or lecturer' link" do
      expect(page).to have_link("Teacher or lecturer")
    end

    it "does not include a standalone 'Teacher' link" do
      expect(page).to have_no_link("Teacher", exact: true)
    end

    it "includes other leadership role links" do
      expect(page).to have_link("Head of year or phase")
      expect(page).to have_link("Head of department or curriculum")
      expect(page).to have_link("Assistant headteacher")
      expect(page).to have_link("Deputy headteacher")
      expect(page).to have_link("Headteacher")
      expect(page).to have_link("SENDCo (special educational needs and disabilities coordinator)")
      expect(page).to have_link("Other leadership roles")
    end
  end

  describe "support roles" do
    it "includes support role links" do
      expect(page).to have_link("Teaching assistant")
      expect(page).to have_link("HLTA (higher level teaching assistant)")
      expect(page).to have_link("Learning support or cover supervisor")
    end
  end

  describe "school phases" do
    it "includes school phase links" do
      expect(page).to have_link("Nursery")
      expect(page).to have_link("Primary")
      expect(page).to have_link("Secondary")
      expect(page).to have_link("Sixth form and college")
      expect(page).to have_link("All through school")
    end
  end

  describe "school subjects" do
    it "includes core subject links" do
      expect(page).to have_link("Maths")
      expect(page).to have_link("English and Media Studies")
      expect(page).to have_link("Physical Education")
      expect(page).to have_link("Science")
    end

    it "includes further subject links" do
      expect(page).to have_link("History")
      expect(page).to have_link("Geography")
      expect(page).to have_link("ICT and Computer Science")
      expect(page).to have_link("Economics and Business Studies")
      expect(page).to have_link("Art and design")
    end

    it "includes science sub-group links" do
      expect(page).to have_link("Chemistry")
      expect(page).to have_link("Biology")
      expect(page).to have_link("Physics")
    end

    it "includes modern foreign languages sub-group links" do
      expect(page).to have_link("Foreign Languages")
      expect(page).to have_link("French")
      expect(page).to have_link("Spanish")
      expect(page).to have_link("German")
    end
  end

  describe "the 'Teaching jobs by subject' accordion" do
    it "is no longer a separate top-level accordion section" do
      expect(page).to have_no_text("Teaching jobs by subject")
    end
  end
end
