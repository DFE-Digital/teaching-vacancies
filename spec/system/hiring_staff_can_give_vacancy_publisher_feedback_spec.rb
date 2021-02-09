require "rails_helper"
RSpec.describe "Hiring staff can give vacancy publisher feedback" do
  let(:school) { create(:school) }
  let(:oid) { SecureRandom.uuid }
  let(:choose_yes_to_participation) do
    choose("publishers-vacancies-vacancy-publisher-feedback-form-user-participation-response-interested-field")
  end
  let(:choose_no_to_participation) do
    choose("publishers-vacancies-vacancy-publisher-feedback-form-user-participation-response-uninterested-field")
  end
  let(:comment) { "Perfect!" }
  let(:email) { "my@valid.email" }

  before { stub_publishers_auth(urn: school.urn, oid: oid) }

  context "The feedback page can not be accessed for a draft job post" do
    let(:draft_job) { create(:vacancy, :complete, :draft) }

    before { draft_job.organisation_vacancies.create(organisation: school) }

    scenario "can not be accessed for non-published vacancies" do
      visit new_organisation_job_feedback_path(draft_job.id)

      expect(page).to have_content("Page not found")
    end
  end

  context "The feedback page can not be accessed for a vacancy that has already received feedback" do
    let(:published_job) { create(:vacancy, :complete) }

    before { published_job.organisation_vacancies.create(organisation: school) }

    scenario "can not be accessed for non-published vacancies" do
      create(:vacancy_publish_feedback, vacancy: published_job)

      visit new_organisation_job_feedback_path(published_job.id)

      expect(page).to have_content(I18n.t("publishers.vacancies.vacancy_publisher_feedbacks.new.already_submitted"))
    end
  end

  context "Submiting feedback for a published vacancy" do
    let(:published_job) { create(:vacancy, :complete) }

    before { published_job.organisation_vacancies.create(organisation: school) }

    scenario "must have a participation response" do
      visit new_organisation_job_feedback_path(published_job.id)
      fill_in "publishers_vacancies_vacancy_publisher_feedback_form[comment]", with: comment

      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content("Please indicate if you'd like to participate in user research")
    end

    scenario "must have an email when participation response is Yes" do
      visit new_organisation_job_feedback_path(published_job.id)
      choose_yes_to_participation

      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content("Enter your email address")
    end

    scenario "Can be successfully submitted for a published vacancy" do
      visit new_organisation_job_feedback_path(published_job.id)

      fill_in "publishers_vacancies_vacancy_publisher_feedback_form[comment]", with: comment
      choose_no_to_participation

      click_on I18n.t("buttons.submit_feedback")
      expect(page).to have_content(
        strip_tags(I18n.t("messages.jobs.feedback.submitted_html", job_title: published_job.job_title)),
      )
    end

    scenario "creates a feedback record" do
      visit new_organisation_job_feedback_path(published_job.id)

      fill_in "publishers_vacancies_vacancy_publisher_feedback_form[comment]", with: comment
      choose_yes_to_participation
      fill_in "publishers_vacancies_vacancy_publisher_feedback_form[email]", with: email

      expect { click_on I18n.t("buttons.submit_feedback") }.to have_triggered_event(:feedback_provided)
        .with_data(comment: comment,
                   email: email,
                   feedback_type: "vacancy_publisher",
                   user_participation_response: "interested",
                   vacancy_id: published_job.id)

      expect(Feedback.vacancy_publisher.last.comment).to eq(comment)
    end
  end
end
