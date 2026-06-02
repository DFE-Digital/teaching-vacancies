require "rails_helper"

RSpec.describe "Jobseeker views the 'Further education jobs by role, phase and subject' accordion" do
  before { visit root_path }

  describe "accordion section heading" do
    it "displays the further education accordion heading" do
      expect(page).to have_text("Further education jobs by role, phase and subject")
    end
  end

  describe "teaching and leadership roles" do
    it "has a 'Teaching and leadership roles' group heading" do
      expect(page).to have_text("Teaching and leadership roles")
    end

    it "includes a 'Teacher or lecturer' link" do
      expect(page).to have_link("Teacher or lecturer")
    end
  end

  describe "education phases" do
    it "has a 'College phase' group heading" do
      expect(page).to have_text("College phase")
    end

    it "includes a 'Sixth form and college' link" do
      expect(page).to have_link("Sixth form and college")
    end
  end

  describe "working patterns" do
    it "has a 'Working patterns' group heading" do
      expect(page).to have_text("Working patterns")
    end

    it "includes a 'Full time' link" do
      expect(page).to have_link("Full time")
    end

    it "includes a 'Part time' link" do
      expect(page).to have_link("Part time")
    end

    it "includes a 'Job share' link" do
      expect(page).to have_link("Job share")
    end
  end

  describe "subjects" do
    it "has a 'Subjects' group heading" do
      expect(page).to have_text("Subjects")
    end

    it "includes core school and college subject links" do
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
      expect(page).to have_link("Dance, Drama and Music")
      expect(page).to have_link("Food technology")
      expect(page).to have_link("Health and Social Care")
      expect(page).to have_link("Design and technology")
      expect(page).to have_link("Politics, Humanities and Social Sciences")
      expect(page).to have_link("Psychology, Sociology and RE")
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
      expect(page).to have_link("Mandarin")
      expect(page).to have_link("Classics")
    end
  end
end
