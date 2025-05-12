require "rails_helper"

RSpec.describe JobApplicationReviewComponent, type: :component do
  subject(:component) { described_class.new(*args, **kwargs) }

  let(:args) { [job_application] }
  let(:kwargs) do
    {}
  end

  let(:job_application) { create(:job_application) }

  it_behaves_like ReviewComponent

  it "does not render a task list by default" do
    render_inline(component)
    expect(page).not_to have_css("ul.review-component__sections")
  end

  context "if sections are provided" do
    before do
      component.with_section(:referees)
      component.with_section(:declarations)
      component.with_above { "<p id='above'>Above</p>".html_safe }
      component.with_below { "<p id='below'>Below</p>".html_safe }

      render_inline(component)
    end

    it "renders each section as part of a task list, between 'above' and 'below'" do
      expect(page).to have_css("ul.review-component__sections")
      # The 'action' element on each card has an 'li' element too
      expect(page).to have_css("ul.review-component__sections li", count: 4)
      expect(page).to have_css("p#above + ul.review-component__sections")
      expect(page).to have_css("ul.review-component__sections + p#below")
    end
  end
end
