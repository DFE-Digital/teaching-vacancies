require "rails_helper"

RSpec.describe "jobseekers/saved_jobs/index" do
  subject(:index_view) { Capybara.string(rendered) }

  let(:active_vacancy) { build_stubbed(:vacancy, enable_job_applications: true) }
  let(:expired_vacancy) { build_stubbed(:vacancy, :expired, enable_job_applications: true) }

  let(:active_saved_job) do
    instance_double(SavedJobDecorator,
                    vacancy: active_vacancy,
                    created_at: Time.current,
                    action: :apply,
                    id: SecureRandom.uuid,
                    job_application: nil)
  end

  let(:expired_saved_job) do
    instance_double(SavedJobDecorator,
                    vacancy: expired_vacancy,
                    created_at: Time.current,
                    action: nil,
                    id: SecureRandom.uuid,
                    job_application: nil)
  end

  before do
    without_partial_double_verification do
      allow(view).to receive_messages(
        sort: Jobseekers::SavedJobSort.new,
        saved_jobs: saved_jobs,
        vacancy_job_location: "",
      )
    end
    render
  end

  describe "when there are saved jobs" do
    let(:saved_jobs) { [expired_saved_job, active_saved_job] }

    it "renders a card for each saved job in order" do
      cards = index_view.all(".card-component")
      expect(cards.count).to eq(2)
      expect(cards[0]).to have_css(".card-component__header", text: expired_vacancy.job_title)
      expect(cards[1]).to have_css(".card-component__header", text: active_vacancy.job_title)
    end

    it "shows the job closed tag only for the expired vacancy" do
      expect(index_view.find(".card-component", text: expired_vacancy.job_title)).to have_css(".govuk-tag", text: "job closed")
      expect(index_view.find(".card-component", text: active_vacancy.job_title)).to have_no_css(".govuk-tag", text: "job closed")
    end

    it "shows a delete link for each saved job" do
      expect(index_view).to have_link(I18n.t("jobseekers.saved_jobs.index.delete"), count: 2)
    end

    context "when action is :apply" do
      it "shows the apply link" do
        expect(index_view.find(".card-component", text: active_vacancy.job_title))
          .to have_link(I18n.t("jobseekers.saved_jobs.index.apply"),
                        href: new_jobseekers_job_job_application_path(active_vacancy.id))
      end

      it "shows no apply link for the expired vacancy" do
        expect(index_view.find(".card-component", text: expired_vacancy.job_title))
          .to have_no_link(I18n.t("jobseekers.saved_jobs.index.apply"))
      end
    end

    context "when action is :view" do
      let(:job_application) { build_stubbed(:job_application, :status_submitted, vacancy: active_vacancy) }
      let(:active_saved_job) do
        instance_double(SavedJobDecorator,
                        vacancy: active_vacancy,
                        created_at: Time.current,
                        action: :view,
                        id: SecureRandom.uuid,
                        job_application: job_application)
      end

      it "shows the view application link" do
        expect(index_view.find(".card-component", text: active_vacancy.job_title))
          .to have_link(I18n.t("jobseekers.saved_jobs.index.view"),
                        href: jobseekers_job_application_path(job_application))
      end

      it "shows no apply or continue link" do
        card = index_view.find(".card-component", text: active_vacancy.job_title)
        expect(card).to have_no_link(I18n.t("jobseekers.saved_jobs.index.apply"))
        expect(card).to have_no_link(I18n.t("jobseekers.saved_jobs.index.continue"))
      end
    end

    context "when action is :continue" do
      let(:job_application) { build_stubbed(:job_application, vacancy: active_vacancy) }
      let(:active_saved_job) do
        instance_double(SavedJobDecorator,
                        vacancy: active_vacancy,
                        created_at: Time.current,
                        action: :continue,
                        id: SecureRandom.uuid,
                        job_application: job_application)
      end

      it "shows the continue application link" do
        expect(index_view.find(".card-component", text: active_vacancy.job_title))
          .to have_link(I18n.t("jobseekers.saved_jobs.index.continue"),
                        href: jobseekers_job_application_review_path(job_application))
      end

      it "shows no apply or view link" do
        card = index_view.find(".card-component", text: active_vacancy.job_title)
        expect(card).to have_no_link(I18n.t("jobseekers.saved_jobs.index.apply"))
        expect(card).to have_no_link(I18n.t("jobseekers.saved_jobs.index.view"))
      end
    end

    context "when action is nil (vacancy not accepting applications)" do
      it "shows no action links" do
        card = index_view.find(".card-component", text: expired_vacancy.job_title)
        expect(card).to have_no_link(I18n.t("jobseekers.saved_jobs.index.apply"))
        expect(card).to have_no_link(I18n.t("jobseekers.saved_jobs.index.view"))
        expect(card).to have_no_link(I18n.t("jobseekers.saved_jobs.index.continue"))
      end
    end
  end

  describe "when there are no saved jobs" do
    let(:saved_jobs) { [] }

    it "shows the zero saved jobs state" do
      expect(index_view).to have_content(I18n.t("jobseekers.saved_jobs.index.zero_saved_jobs_title"))
    end
  end
end
