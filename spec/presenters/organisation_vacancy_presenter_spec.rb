require "rails_helper"
RSpec.describe OrganisationVacancyPresenter do
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:presenter) { described_class.new(vacancy) }

  describe "application_deadline" do
    let(:vacancy) { build_stubbed(:vacancy, expires_at: Time.current + 5.days) }
    let(:expected_deadline) { "#{format_date(Date.current + 5.days)} at #{format_time(Time.current + 5.days)}" }

    it "displays the application deadline date" do
      expect(presenter.application_deadline).to eq(expected_deadline)
    end
  end

  describe "days_to_apply" do
    let(:vacancy) { build_stubbed(:vacancy, expires_at: time_to_apply) }

    context "when the deadline is today" do
      let(:time_to_apply) { (Date.current + 12.hours) }

      it "displays that the deadline is today" do
        expect(presenter.days_to_apply).to eq("Deadline is today")
      end
    end

    context "when the deadline is tomorrow" do
      context "and less than 24 hours away" do
        let(:time_to_apply) { Time.zone.tomorrow }

        it "displays that the deadline is tomorrow" do
          expect(presenter.days_to_apply).to eq("Deadline is tomorrow")
        end
      end

      context "and more than 24 hours away" do
        let(:time_to_apply) { (Time.current + 24.hours + 1.second) }

        it "displays that the deadline is tomorrow" do
          expect(presenter.days_to_apply).to eq("Deadline is tomorrow")
        end
      end
    end

    context "with more than 2 days to apply" do
      let(:time_to_apply) { (Time.current + 3.days) }

      it "displays a countdown in days" do
        expect(presenter.days_to_apply).to eq("3 days remaining to apply")
      end
    end
  end
end
