require "rails_helper"
RSpec.describe "Publishers can provide feedback on expired vacancies via the prompt email" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher, email: "test@example.com") }

  before { ActionMailer::Base.deliveries.clear }

  context "when no publishers have vacancies that expired between 2 and 6 weeks ago" do
    before do
      create(:vacancy, :published, publisher: publisher, expires_at: 1.week.ago)
      perform_enqueued_jobs do
        SendExpiredVacancyFeedbackPromptJob.new.perform
      end
    end

    scenario "they do not receive the feedback prompt email" do
      expect(ApplicationMailer.deliveries.count).to eq(0)
    end
  end

  context "when a publisher has vacancies that expired between 2 and 6 weeks ago" do
    let(:first_vacancy_in_email) { Vacancy.order(:expires_at).first }

    before do
      create_list(:vacancy, 5, :published, publisher: publisher, expires_at: 4.weeks.ago)
      perform_enqueued_jobs do
        SendExpiredVacancyFeedbackPromptJob.new.perform
      end
    end

    scenario "they receive the feedback prompt email" do
      expect(ApplicationMailer.deliveries.count).to eq(1)
    end

    scenario "they can provide feedback" do
      visit first_link_from_last_mail

      expect(current_path).to eq(new_organisation_job_expired_feedback_path(first_vacancy_in_email.signed_id))

      choose I18n.t("helpers.label.publishers_job_listing_expired_feedback_form.hired_status_options.hired_tvs")
      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content(I18n.t("activemodel.errors.models.publishers/job_listing/expired_feedback_form.attributes.listed_elsewhere.inclusion"))

      choose I18n.t("helpers.label.publishers_job_listing_expired_feedback_form.hired_status_options.hired_tvs")
      choose I18n.t("helpers.label.publishers_job_listing_expired_feedback_form.listed_elsewhere_options.listed_free")

      expect {
        click_button I18n.t("buttons.submit_feedback")
        first_vacancy_in_email.reload
      }.to change { first_vacancy_in_email.hired_status }.from(nil).to("hired_tvs")
       .and change { first_vacancy_in_email.listed_elsewhere }.from(nil).to("listed_free")

      expect(current_path).to eq(submitted_organisation_job_expired_feedback_path(first_vacancy_in_email.signed_id))
    end
  end

  context "when multiple publishers have vacancies that expired between 2 and 6 weeks ago" do
    let(:second_publisher) { create(:publisher, email: "test2@example.com") }

    before do
      create_list(:vacancy, 5, :published, publisher: publisher, expires_at: 4.weeks.ago)
      create_list(:vacancy, 5, :published, publisher: second_publisher, expires_at: 4.weeks.ago)
      perform_enqueued_jobs do
        SendExpiredVacancyFeedbackPromptJob.new.perform
      end
    end

    scenario "they all receive a feedback prompt email" do
      expect(ApplicationMailer.deliveries.map(&:to)).to match a_collection_containing_exactly(["test@example.com"], ["test2@example.com"])
      expect(ApplicationMailer.deliveries.count).to eq(2)
    end
  end
end
