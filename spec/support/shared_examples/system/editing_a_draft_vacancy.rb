RSpec.shared_examples "provides an overview of the draft vacancy form" do
  let(:step_process) do
    Publishers::Vacancies::VacancyStepProcess.new(
      :review,
      vacancy: vacancy,
      organisation: organisation,
    )
  end

  before do
    # Create a "not started" group
    vacancy.update(
      salary: nil,
      benefits: nil,
      completed_steps: vacancy.completed_steps - %w[pay_package],
    )

    # Create an "action required" group
    vacancy.update(working_patterns: nil)

    visit organisation_path(organisation)
    click_on "Draft jobs"
    click_on vacancy.job_title
  end

  it "indicates that you're reviewing a draft" do
    expect(page).to have_css("h1", text: "Manage draft listing")
  end

  it "shows the status of each stage" do
    top_level_steps = step_process.step_groups.keys - %i[documents review]
    completed_steps = top_level_steps - %i[pay_package working_patterns]

    completed_steps.each do |step_name|
      expect(page).to have_step_status(step_name, status: "complete")
    end

    expect(page).to have_step_status(:pay_package, status: "not started")
    expect(page).to have_step_status(:working_patterns, status: "action required")
  end

  it "shows the overview without errors when updating a section" do
    within "#job_details" do
      click_on "Change"
    end

    click_on "Update listing"

    expect(page).to have_css("h1", text: "Manage draft listing")
    expect(page).not_to have_link("Enter a salary")
  end

  context "when incomplete and submitted for publication" do
    before do
      expect(page).not_to have_css(".govuk-error-summary")
      click_on "Confirm and submit job"
    end

    it "provides top-of-page validation errors which link to the relevant form parts" do
      within ".govuk-error-summary" do
        expect(page).to have_link("Enter a salary", href: organisation_job_build_path(job_id: vacancy.id, id: "pay_package", back_to: "manage_draft"))
      end
    end

    it "provides inline validation errors which link to the relevant form parts" do
      within "#pay_package .app-inset-text--error" do
        expect(page).to have_link("Enter a salary", href: organisation_job_build_path(job_id: vacancy.id, id: "pay_package", back_to: "manage_draft"))
      end
    end
  end

  context "when incomplete and previewed" do
    before do
      expect(page).not_to have_css(".govuk-error-summary")
      click_on "Preview job listing"
    end

    it "provides top-of-page validation errors which link to the relevant form parts" do
      within ".govuk-error-summary" do
        expect(page).to have_link("Enter a salary", href: organisation_job_build_path(job_id: vacancy.id, id: "pay_package", back_to: "manage_draft"))
      end
    end

    it "provides inline validation errors which link to the relevant form parts" do
      within "#pay_package .app-inset-text--error" do
        expect(page).to have_link("Enter a salary", href: organisation_job_build_path(job_id: vacancy.id, id: "pay_package", back_to: "manage_draft"))
      end
    end
  end

  context "when completed and submitted" do
    before do
      click_on "Confirm and submit job"
      expect(vacancy).not_to be_published

      within "#pay_package" do
        click_on "Enter a salary"
      end

      fill_in "Annual or full time equivalent (FTE) salary", with: "£60,000"
      click_on "Update listing"

      click_on "Confirm and submit job"

      within ".review-component__section#working_patterns" do
        click_on "Select a working pattern"
      end

      check "Full time"
      click_on "Update listing"

      click_on "Confirm and submit job"
    end

    it "publishes the draft" do
      expect(vacancy.reload).to be_published
    end
  end

  context "when completed and previewed" do
    before do
      click_on "Preview job listing"
      expect(page).not_to have_text("Preview of ‘#{vacancy.job_title}’")

      within "#pay_package" do
        click_on "Enter a salary"
      end

      fill_in "Annual or full time equivalent (FTE) salary", with: "£60,000"
      click_on "Update listing"

      click_on "Preview job listing"

      within ".review-component__section#working_patterns" do
        click_on "Select a working pattern"
      end

      check "Full time"
      click_on "Update listing"

      click_on "Preview job listing"
    end

    it "shows the preview" do
      expect(page).to have_text("Preview of ‘#{vacancy.job_title}’")
    end
  end

  def have_step_status(step, status:)
    have_css(
      "##{step} .review-component__section__heading__status",
      text: status,
    )
  end
end
