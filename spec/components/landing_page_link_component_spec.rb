require "rails_helper"

RSpec.describe LandingPageLinkComponent, type: :component do
  describe "vacancy counts for 'School jobs by role, phase and subject' accordion" do
    describe "renamed 'Teacher or lecturer' link" do
      before do
        create_list(:vacancy, 3, job_roles: %w[teacher])
        create(:vacancy, job_roles: %w[headteacher])
      end

      it "shows the correct count next to 'Teacher or lecturer'" do
        render_inline(described_class.new(LandingPage["teacher-jobs"]))
        expect(page).to have_text("Teacher or lecturer")
        expect(page).to have_css("span[aria-hidden='true']", text: "(3)")
      end

      it "excludes non-teacher vacancies from the count" do
        render_inline(described_class.new(LandingPage["teacher-jobs"]))
        expect(page).to have_no_css("span[aria-hidden='true']", text: "(4)")
      end
    end

    describe "other teaching and leadership roles" do
      before do
        create_list(:vacancy, 2, job_roles: %w[headteacher])
        create(:vacancy, job_roles: %w[teacher])
      end

      it "shows the correct count for 'Headteacher'" do
        render_inline(described_class.new(LandingPage["headteacher-jobs"]))
        expect(page).to have_css("span[aria-hidden='true']", text: "(2)")
      end
    end

    describe "support roles" do
      before do
        create_list(:vacancy, 2, job_roles: %w[teaching_assistant])
        create(:vacancy, job_roles: %w[teacher])
      end

      it "shows the correct count for 'Teaching assistant'" do
        render_inline(described_class.new(LandingPage["teaching-assistant-jobs"]))
        expect(page).to have_css("span[aria-hidden='true']", text: "(2)")
      end
    end

    describe "school phases" do
      before do
        create_list(:vacancy, 4, phases: %w[primary])
        create(:vacancy, phases: %w[secondary])
      end

      it "shows the correct count for 'Primary'" do
        render_inline(described_class.new(LandingPage["primary-school-jobs"]))
        expect(page).to have_css("span[aria-hidden='true']", text: "(4)")
      end
    end

    describe "subject links (absorbed from the former 'Teaching jobs by subject' accordion)" do
      before do
        create_list(:vacancy, 3, :secondary, subjects: %w[Mathematics])
        create(:vacancy, :secondary, subjects: %w[English])
      end

      it "shows the correct count for 'Maths'" do
        render_inline(described_class.new(LandingPage["maths-teacher-jobs"]))
        expect(page).to have_css("span[aria-hidden='true']", text: "(3)")
      end

      it "excludes non-matching subjects from the count" do
        render_inline(described_class.new(LandingPage["maths-teacher-jobs"]))
        expect(page).to have_no_css("span[aria-hidden='true']", text: "(4)")
      end
    end
  end
end
