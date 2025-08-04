require "rails_helper"

RSpec.describe "Publishers can manage job applications for a vacancy" do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  describe "through job application page actions" do
    let(:job_application) { create(:job_application, :status_submitted, vacancy:) }

    before do
      publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
    end

    it "updates job application status", :js do
      publisher_application_page.update_status do |tag_page|
        tag_page.select_and_submit("shortlisted")
      end

      # TODO: should the redirection points to the job application page instead?
      expect(publisher_ats_applications_page).to be_displayed(vacancy_id: vacancy.id)

      expect(publisher_ats_applications_page.tab_panel.job_applications.first.mapped_status).to eq(job_application.reload.status)
    end
  end

  describe "through vacancy applications page actions", :js do
    %i[alan charlie etha hanane said yun britany].each do |first_name|
      let(first_name) { create(:job_application, :status_submitted, vacancy:, first_name:) }
    end
    let(:job_applications) { [alan, charlie, etha, hanane, said, yun, britany] }
    let(:current_page) { publisher_ats_applications_page }

    before do
      job_applications
      publisher_ats_applications_page.load(vacancy_id: vacancy.id)
    end

    it "progress job applications" do
      expect(current_page.job_title).to have_text(vacancy.job_title)

      # navigation
      expect(current_page.nav.current_item).to have_text("Applications")

      current_page.select_tab(:tab_submitted)

      # job application panel
      expect(current_page.selected_tab).to have_text("New")
      expect(current_page.tab_panel.heading).to have_text("New Applications")
      expect(current_page.tab_panel.job_applications.count).to eq(job_applications.count)
      job_applications.each do |applicant|
        job_application = current_page.candidate(applicant)
        expect(job_application.name).to have_text(applicant.name)
        expect(job_application.mapped_status).to eq(applicant.reload.status)
      end

      # count for tabs other than current tab
      {
        tab_all: job_applications.count,
        tab_submitted: job_applications.count,
        tab_not_considering: 0,
        tab_shortlisted: 0,
        tab_interviewing: 0,
      }.each do |tab_id, count|
        expect(current_page.get_tab(tab_id)).to have_text("(#{count})")
      end

      # shortlist some applications
      current_page.update_status(charlie, etha, hanane, said, yun) do |tag_page|
        tag_page.select_and_submit("shortlisted")
      end

      # job application panel
      expect(current_page.selected_tab).to have_text("New")
      [alan, britany].each do |applicant|
        job_application = current_page.candidate(applicant)
        expect(job_application.name).to have_text(applicant.name)
        expect(job_application.mapped_status).to eq(applicant.reload.status)
      end

      {
        tab_all: job_applications.count,
        tab_submitted: 2,
        tab_not_considering: 0,
        tab_shortlisted: 5,
        tab_interviewing: 0,
      }.each do |tab_id, count|
        expect(current_page.get_tab(tab_id)).to have_text("(#{count})")
      end

      # reject britany
      current_page.update_status(britany) do |tag_page|
        tag_page.select_and_submit("unsuccessful")
      end

      expect(current_page.selected_tab).to have_text("New")
      {
        tab_all: job_applications.count,
        tab_submitted: 1,
        tab_not_considering: 1,
        tab_shortlisted: 5,
        tab_interviewing: 0,
      }.each do |tab_id, count|
        expect(current_page.get_tab(tab_id)).to have_text("(#{count})")
      end

      # action review applicant
      current_page.update_status(alan) do |tag_page|
        tag_page.select_and_submit("reviewed")
      end
      {
        tab_all: job_applications.count,
        tab_submitted: 1,
        tab_not_considering: 1,
        tab_shortlisted: 5,
        tab_interviewing: 0,
      }.each do |tab_id, count|
        expect(current_page.get_tab(tab_id)).to have_text("(#{count})")
      end
      expect(current_page.selected_tab).to have_text("New")
      expect(current_page.tab_panel.job_applications[0].name).to have_text(alan.name)
      expect(current_page.tab_panel.job_applications[0].mapped_status).to eq(alan.reload.status)

      #
      # display not considering tab
      #
      current_page.select_tab(:tab_not_considering)

      expect(current_page.selected_tab).to have_text("Not Considering")
      expect(current_page.tab_panel.job_applications[0].name).to have_text(britany.name)
      expect(current_page.tab_panel.job_applications[0].mapped_status).to eq(britany.reload.status)

      #
      # display shortlisted tab
      #
      current_page.select_tab(:tab_shortlisted)

      expect(current_page.selected_tab).to have_text("Shortlisted")
      [charlie, etha, hanane, said, yun].each do |applicant|
        job_application = current_page.candidate(applicant)
        expect(job_application.name).to have_text(applicant.name)
        expect(job_application.mapped_status).to eq(applicant.reload.status)
      end

      #
      # progress applicants
      #
      current_page.update_status(etha, hanane) do |tag_page|
        tag_page.select_and_submit("interviewing")
      end
      {
        tab_all: job_applications.count,
        tab_submitted: 1,
        tab_not_considering: 1,
        tab_shortlisted: 3,
        tab_interviewing: 2,
      }.each do |tab_id, count|
        expect(current_page.get_tab(tab_id)).to have_text("(#{count})")
      end
      expect(current_page.selected_tab).to have_text("Shortlisted")
      [charlie, said, yun].each do |applicant|
        job_application = current_page.candidate(applicant)
        expect(job_application.name).to have_text(applicant.name)
        expect(job_application.mapped_status).to eq(applicant.reload.status)
      end

      #
      # applicant withdraws
      #
      said.withdrawn!

      #
      # reload page and select shortlisted tab
      #
      publisher_ats_applications_page.load(vacancy_id: vacancy.id)
      current_page.select_tab(:tab_shortlisted)

      {
        tab_all: job_applications.count,
        tab_submitted: 1,
        tab_not_considering: 1,
        tab_shortlisted: 2,
        tab_interviewing: 2,
      }.each do |tab_id, count|
        expect(current_page.get_tab(tab_id)).to have_text("(#{count})")
      end
      expect(current_page.selected_tab).to have_text("Shortlisted")
      [charlie, yun].each do |applicant|
        job_application = current_page.candidate(applicant)
        expect(job_application.name).to have_text(applicant.name)
        expect(job_application.mapped_status).to eq(applicant.reload.status)
      end

      #
      # dispaly interviewing tab
      #
      current_page.select_tab(:tab_interviewing)

      expect(current_page.selected_tab).to have_text("Interviewing")
      [etha, hanane].each do |applicant|
        job_application = current_page.candidate(applicant)
        expect(job_application.name).to have_text(applicant.name)
        expect(job_application.mapped_status).to eq(applicant.reload.status)
      end

      #
      # display all tab
      #
      current_page.select_tab(:tab_all)

      expect(current_page.selected_tab).to have_text("All")
      expect(current_page).to have_text(said.name)
    end
  end
end
