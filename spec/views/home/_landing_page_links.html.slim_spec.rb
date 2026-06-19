require "rails_helper"

RSpec.describe "home/_landing_page_links" do
  let(:empty_counts) do
    HomeController::VacancyCounts.new(
      role_counts: {},
      phase_counts: {},
      working_pattern_counts: {},
      subjects_counts: {},
    )
  end

  before do
    render partial: "home/landing_page_links",
           locals: { school_counts: empty_counts, fe_counts: empty_counts }
  end

  describe "school jobs accordion section" do
    it "displays the school jobs accordion heading" do
      expect(rendered).to have_text("School jobs by role, phase and subject")
    end

    describe "teaching and leadership roles" do
      it "includes a 'Teacher or lecturer' link" do
        expect(rendered).to have_link("Teacher or lecturer")
      end

      it "does not include a standalone 'Teacher' link" do
        expect(rendered).to have_no_link("Teacher", exact: true)
      end

      it "includes other leadership role links" do
        expect(rendered).to have_link("Head of year or phase")
        expect(rendered).to have_link("Head of department or curriculum")
        expect(rendered).to have_link("Assistant headteacher")
        expect(rendered).to have_link("Deputy headteacher")
        expect(rendered).to have_link("Headteacher")
        expect(rendered).to have_link("SENDCo (special educational needs and disabilities coordinator)")
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
      it "includes core subject links" do
        expect(rendered).to have_link("Maths")
        expect(rendered).to have_link("English and Media Studies")
        expect(rendered).to have_link("Physical Education")
        expect(rendered).to have_link("Science")
      end

      it "includes further subject links" do
        expect(rendered).to have_link("History")
        expect(rendered).to have_link("Geography")
        expect(rendered).to have_link("ICT and Computer Science")
        expect(rendered).to have_link("Economics and Business Studies")
        expect(rendered).to have_link("Art and design")
      end

      it "includes science sub-group links" do
        expect(rendered).to have_link("Chemistry")
        expect(rendered).to have_link("Biology")
        expect(rendered).to have_link("Physics")
      end

      it "includes modern foreign languages sub-group links" do
        expect(rendered).to have_link("Foreign Languages")
        expect(rendered).to have_link("French")
        expect(rendered).to have_link("Spanish")
        expect(rendered).to have_link("German")
      end
    end

    it "does not include a separate 'Teaching jobs by subject' accordion section" do
      expect(rendered).to have_no_text("Teaching jobs by subject")
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

    describe "education phases" do
      it "has a 'College phase' group heading" do
        expect(rendered).to have_text("College phase")
      end

      it "includes a 'Sixth form and college' link" do
        expect(rendered).to have_link("Sixth form and college")
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
      it "has a 'Subjects' group heading" do
        expect(rendered).to have_text("Subjects")
      end

      it "includes FE subject links" do
        expect(rendered).to have_link("Maths")
        expect(rendered).to have_link("English and Media Studies")
        expect(rendered).to have_link("History")
        expect(rendered).to have_link("Geography")
        expect(rendered).to have_link("ICT and Computer Science")
        expect(rendered).to have_link("Economics and Business Studies")
        expect(rendered).to have_link("Dance, Drama and Music")
        expect(rendered).to have_link("Food technology")
        expect(rendered).to have_link("Health and Social Care")
        expect(rendered).to have_link("Design and technology")
        expect(rendered).to have_link("Politics, Humanities and Social Sciences")
        expect(rendered).to have_link("Psychology, Sociology and RE")
      end
    end
  end
end
