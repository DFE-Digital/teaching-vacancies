require "rails_helper"

RSpec.describe SendDailyAlertEmailJob do
  subject(:job) { described_class.perform_later }

  describe "#perform" do
    let(:mail) { double(:mail, deliver_later: nil) }

    context "with vacancies" do
      before do
        create(:vacancy, :published_slugged, job_roles: %w[headteacher], visa_sponsorship_available: false, ect_status: :ect_unsuitable, subjects: %w[German], phases: %w[secondary], working_patterns: %w[full_time])
      end

      context "with keyword" do
        let(:subscription) { create(:daily_subscription, keyword: keyword) }
        let(:nice_job) { Vacancy.find_by!(contact_number: "9") }

        before do
          create(:vacancy, :published_slugged, contact_number: "9", job_title: "This is a Really Nice job", job_roles: %w[headteacher], phases: %w[secondary], working_patterns: %w[full_time])
        end

        context "with plain keyword" do
          let(:keyword) { "nice" }

          it "only finds the nice job" do
            expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [nice_job].pluck(:id)) { mail }
            perform_enqueued_jobs { job }
          end
        end

        context "with keyword caps and trailing space" do
          let(:keyword) { "Nice " }

          it "only finds the nice job" do
            expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [nice_job].pluck(:id)) { mail }
            perform_enqueued_jobs { job }
          end
        end
      end

      # context "with location" do
      #   context "with nationwide location" do
      #     let(:subscription) { create(:daily_subscription, location: "england")}
      #   end
      # end

      context "with teaching job roles" do
        before do
          create(:vacancy, :published_slugged, contact_number: "1", job_roles: %w[teacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:teacher_vacancy) { Vacancy.find_by!(contact_number: "1") }
        let(:subscription) { create(:subscription, teaching_job_roles: %w[teacher], frequency: :daily) }

        it "only finds the teaching job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [teacher_vacancy].pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "with support job roles" do
        before do
          create(:vacancy, :published_slugged, contact_number: "2", job_roles: %w[it_support], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:support_vacancy) { Vacancy.find_by!(contact_number: "2") }
        let(:subscription) { create(:subscription, support_job_roles: %w[it_support], frequency: :daily) }

        it "only finds the support job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [support_vacancy].pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "with visa sponsorship" do
        before do
          create(:vacancy, :published_slugged, contact_number: "3", visa_sponsorship_available: true, job_roles: %w[headteacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:visa_job) { Vacancy.find_by!(contact_number: "3") }
        let(:subscription) { create(:subscription, :visa_sponsorship_required, frequency: :daily) }

        it "only finds the visa job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [visa_job].pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "with ECT" do
        before do
          create(:vacancy, :published_slugged, contact_number: "4", ect_status: :ect_suitable, job_roles: %w[headteacher teacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
          create(:vacancy, :published_slugged, ect_status: nil, job_roles: %w[headteacher teacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:subscription) { create(:subscription, :ect_suitable, frequency: :daily) }
        let(:ect_job) { Vacancy.find_by!(contact_number: "4") }

        it "only finds the ECT job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [ect_job].pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "with subjects filter" do
        before do
          create(:vacancy, :published_slugged, contact_number: "5", job_roles: %w[headteacher], subjects: %w[French], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:french_job) { Vacancy.find_by!(contact_number: "5") }
        let(:subscription) { create(:subscription, subjects: %w[French], frequency: :daily) }

        it "only finds the French job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [french_job].pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "with phases filter" do
        before do
          create(:vacancy, :published_slugged, contact_number: "6", job_roles: %w[headteacher], phases: %w[primary], working_patterns: %w[full_time])
        end

        let(:subscription) { create(:subscription, phases: %w[primary], frequency: :daily) }
        let(:primary_job) { Vacancy.find_by!(contact_number: "6") }

        it "only finds the primary school job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [primary_job].pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "with working patterns filter" do
        before do
          create(:vacancy, :published_slugged, contact_number: "7", job_roles: %w[headteacher], phases: %w[secondary], working_patterns: %w[part_time])
        end

        let(:subscription) { create(:subscription, working_patterns: %w[part_time], frequency: :daily) }
        let(:part_time_job) { Vacancy.find_by!(contact_number: "7") }

        it "only finds the part_time job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [part_time_job].pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "with organisation filter" do
        before do
          create(:vacancy, :published_slugged, contact_number: "8", organisations: [new_org], job_roles: %w[headteacher], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:new_org) { create(:school) }
        let(:new_org_job) { Vacancy.find_by!(contact_number: "8") }
        let(:subscription) { create(:subscription, organisation_slug: new_org.slug, frequency: :daily) }

        it "only finds the new_publisher job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [new_org_job].pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "when a run exists" do
        let(:subscription) { create(:subscription, frequency: :daily) }

        before do
          subscription.alert_runs.create(run_on: Date.current)
        end

        it "does not send another email" do
          expect(Jobseekers::AlertMailer).to_not receive(:alert)
          perform_enqueued_jobs { job }
        end
      end
    end

    context "with old and new vacancies" do
      before do
        create(:vacancy, :published_slugged, contact_number: "2", publish_on: Date.current)
        create(:vacancy, :published_slugged, contact_number: "1", publish_on: 1.day.ago)
      end

      let(:expected_vacancies) { [Vacancy.find_by!(contact_number: "2"), Vacancy.find_by!(contact_number: "1")] }
      let(:subscription) { create(:subscription, frequency: :daily) }

      it "sends the vacancies in publish order descending" do
        expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, expected_vacancies.pluck(:id)) { mail }
        perform_enqueued_jobs { job }
      end
    end

    context "with no vacancies" do
      let(:subscription) { create(:subscription, frequency: :daily) }

      it "does not send an email or create a run" do
        expect(Jobseekers::AlertMailer).to_not receive(:alert)
        perform_enqueued_jobs { job }
        expect(subscription.alert_runs.count).to eq(0)
      end
    end
  end

  describe "#subscriptions" do
    let(:job) { described_class.new }

    it "gets active daily subscriptions" do
      expect(Subscription).to receive_message_chain(:active, :daily).and_return(
        Subscription.where(active: true).where(frequency: :daily),
      )
      job.subscriptions
    end
  end
end
