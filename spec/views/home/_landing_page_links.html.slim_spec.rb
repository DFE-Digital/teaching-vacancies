require "rails_helper"

RSpec.describe "home/landing_page_links" do
  let(:school_counts) do
    HomeController::VacancyCounts.new(
      role_counts: {},
      phase_counts: {},
      working_pattern_counts: {},
      subjects_counts: {},
    )
  end
  let(:fe_counts) do
    HomeController::VacancyCounts.new(
      role_counts: {},
      phase_counts: {},
      working_pattern_counts: {},
      subjects_counts: { Spanish: 1, French: 1, Welsh: 5, "Foreign languages": 7 },
    )
  end
  let(:page) { Capybara.string(rendered) }

  before do
    render partial: "home/landing_page_links",
           locals: { school_counts: school_counts, fe_counts: fe_counts }
  end

  describe "school jobs accordion section" do
    it "displays the school jobs accordion heading" do
      expect(rendered).to have_text("School jobs by role, phase and subject")
    end

    describe "teaching and leadership roles" do
      it "includes a 'Teacher or lecturer' link" do
        expect(rendered).to have_link("Teacher or lecturer")
      end

      it "includes other leadership role links" do
        expect(rendered).to have_link("Head of year or phase")
        expect(rendered).to have_link("Head of department or curriculum")
        expect(rendered).to have_link("Assistant headteacher")
        expect(rendered).to have_link("Deputy headteacher")
        expect(rendered).to have_link("Headteacher")
        expect(rendered).to have_link("SENCo (special educational needs and disabilities coordinator)")
        expect(rendered).to have_link("Other leadership roles")
      end
    end

    describe "support roles" do
      it "includes support role links" do
        expect(rendered).to have_link("Teaching assistant")
        expect(rendered).to have_link("HLTA (higher level teaching assistant)")
        expect(rendered).to have_link("Learning support or cover supervisor")
      end
    end

    describe "school phases" do
      it "includes school phase links" do
        expect(rendered).to have_link("Nursery")
        expect(rendered).to have_link("Primary")
        expect(rendered).to have_link("Secondary")
        expect(rendered).to have_link("Sixth form and college")
        expect(rendered).to have_link("All through school")
      end
    end

    describe "school subjects" do
      let(:section) { page.find_by_id("school_subjects") }

      it "includes core subject links" do
        expect(section).to have_link("Maths")
        expect(section).to have_link("English and media studies")
        expect(section).to have_link("Physical education")
        expect(section).to have_link("Science")
      end

      it "includes further subject links" do
        expect(section).to have_link("History")
        expect(section).to have_link("Geography")
        expect(section).to have_link("ICT and computer science")
        expect(section).to have_link("Economics and business studies")
        expect(section).to have_link("Art and design")
        expect(section).to have_link("Psychology, Sociology and RE")
      end

      it "includes science sub-group links" do
        expect(section).to have_link("Chemistry")
        expect(section).to have_link("Biology")
        expect(section).to have_link("Physics")
      end

      it "includes modern foreign languages sub-group links" do
        expect(section).to have_link("Foreign languages")
        expect(section).to have_link("French")
        expect(section).to have_link("Spanish")
        expect(section).to have_link("German")
      end
    end
  end

  describe "further education jobs accordion section" do
    it "displays the further education accordion heading" do
      expect(rendered).to have_text("Further education jobs by role, phase and subject")
    end

    describe "teaching and leadership roles" do
      it "has a 'Teaching and leadership roles' group heading" do
        expect(rendered).to have_text("Teaching and leadership roles")
      end

      it "includes a 'Teacher or lecturer' link" do
        expect(rendered).to have_link("Teacher or lecturer")
      end
    end

    describe "working patterns" do
      it "has a 'Working patterns' group heading" do
        expect(rendered).to have_text("Working patterns")
      end

      it "includes working pattern links" do
        expect(rendered).to have_link("Full time")
        expect(rendered).to have_link("Part time")
        expect(rendered).to have_link("Job share")
      end
    end

    describe "subjects" do
      let(:section) { page.find_by_id("fe_subjects") }

      it "has language group links with correct counts" do
        expect(section).to have_link("Foreign languages (7)")
        expect(section).to have_link("Welsh (5)")
        expect(section).to have_link("Spanish (1)")
        expect(section).to have_link("French (1)")
      end

      it "has a 'Subjects' group heading" do
        expect(section).to have_text("Subjects")
      end

      it "includes FE subject links" do
        expect(section).to have_link("Maths")
        expect(section).to have_link("English and media studies")
        expect(section).to have_link("History")
        expect(section).to have_link("Geography")
        expect(section).to have_link("Economics and business studies")
        expect(section).to have_link("Dance, drama and music")
        expect(section).to have_link("Food technology")
        expect(section).to have_link("Health and Social Care")
        expect(section).to have_link("Design and technology")
        expect(section).to have_link("Land and Property Management")
      end
    end
  end
end
