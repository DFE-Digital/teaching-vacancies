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
      publish_on: nil,
      expires_at: nil,
      completed_steps: vacancy.completed_steps - %w[important_dates],
    )

    # Create an "action required" group
    vacancy.update(job_advert: nil)

    visit organisation_path(organisation)
    click_on "Draft jobs"
    click_on vacancy.job_title
  end

  it "indicates that you're reviewing a draft" do
    expect(page).to have_css("h1", text: "Manage draft listing")
  end

  it "shows the status of each stage" do
    top_level_steps = step_process.step_groups.keys - %i[documents review]
    invalid_steps = %i[job_summary]
    incomplete_steps = %i[important_dates]
    completed_and_valid_steps = top_level_steps - invalid_steps - incomplete_steps

    completed_and_valid_steps.each do |step_name|
      expect(page).to have_step_status(step_name, status: "complete")
    end

    expect(page).to have_step_status(:important_dates, status: "not started")
    expect(page).to have_step_status(:job_summary, status: "action required")
  end

  it "shows the overview without errors when updating a section" do
    within "#job_details" do
      click_on "Change"
    end

    click_on "Update listing"

    expect(page).to have_css("h1", text: "Manage draft listing")
    expect(page).not_to have_link("Select yes if you want to include additional allowances")
  end

  context "when incomplete and submitted for publication" do
    before do
      expect(page).not_to have_css(".govuk-error-summary")
      click_on "Confirm and submit job"
    end

    it "provides top-of-page validation errors which link to the relevant form parts" do
      within ".govuk-error-summary" do
        expect(page).to have_link("Enter a job advert", href: organisation_job_build_path(job_id: vacancy.id, id: "job_summary", back_to: "manage_draft"))
      end
    end

    it "provides inline validation errors which link to the relevant form parts" do
      within "#job_summary .inset-text--error" do
        expect(page).to have_link("Enter a job advert", href: organisation_job_build_path(job_id: vacancy.id, id: "job_summary", back_to: "manage_draft"))
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
        expect(page).to have_link("Enter a job advert", href: organisation_job_build_path(job_id: vacancy.id, id: "job_summary", back_to: "manage_draft"))
      end
    end

    it "provides inline validation errors which link to the relevant form parts" do
      within "#job_summary .inset-text--error" do
        expect(page).to have_link("Enter a job advert", href: organisation_job_build_path(job_id: vacancy.id, id: "job_summary", back_to: "manage_draft"))
      end
    end
  end

  context "when completed and submitted" do
    before do
      vacancy.update(publish_on: Date.current, expires_at: 2.weeks.from_now)
      click_on "Confirm and submit job"
      expect(vacancy).not_to be_published

      within "#job_summary" do
        click_on "Enter a job advert"
      end

      fill_in "Job advert", with: "It's not a bad place to work"
      click_on "Update listing"

      click_on "Confirm and submit job"

      click_on "Choose the time the application is due from the options provided"
      choose "9am"
      click_on "Update listing"

      click_on "Confirm and submit job"
    end

    it "publishes the draft" do
      expect(vacancy.reload).to be_published
    end
  end

  context "when completed and previewed" do
    before do
      vacancy.update(publish_on: Date.current, expires_at: 2.weeks.from_now)
      click_on "Preview job listing"
      expect(page).not_to have_text("Preview of ‘#{vacancy.job_title}’")

      within "#job_summary" do
        click_on "Enter a job advert"
      end

      fill_in "Job advert", with: "It's not a bad place to work"
      click_on "Update listing"

      click_on "Preview job listing"

      click_on "Choose the time the application is due from the options provided"
      choose "9am"
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
