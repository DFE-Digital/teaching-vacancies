require "rails_helper"

RSpec.describe Subscription do
  it { is_expected.to have_many(:alert_runs) }
  it { is_expected.to respond_to(:recaptcha_score) }

  describe "scopes" do
    before(:each) do
      create_list(:subscription, 3, frequency: :daily)
      create_list(:subscription, 5, frequency: :weekly)
      create(:subscription, frequency: :daily, active: false)
    end

    describe "#daily" do
      it "retrieves all subscriptions with frequency set to :daily" do
        expect(Subscription.daily.count).to eq(4)
      end
    end

    describe "#weekly" do
      it "retrieves all subscriptions with frequency set to :daily" do
        expect(Subscription.weekly.count).to eq(5)
      end
    end

    describe "active" do
      it "retrieves all subscriptions with active set to true" do
        expect(Subscription.active.count).to eq(8)
      end
    end
  end

  context "token generation" do
    before do
      stub_const("SUBSCRIPTION_KEY_GENERATOR_SECRET", "foo")
      stub_const("SUBSCRIPTION_KEY_GENERATOR_SALT", "bar")
    end

    let(:subscription) { create(:subscription, frequency: :daily) }
    let(:token) { subscription.token }

    it "generates a token" do
      expect(token).to_not be_nil
    end

    describe "#find_and_verify_by_token" do
      let(:result) { Subscription.find_and_verify_by_token(token) }

      it "finds by token" do
        expect(result).to eq(subscription)
      end

      context "when token is old" do
        let(:token) { subscription.token }

        it "finds by token" do
          travel 3.days do
            expect(result).to eq(subscription)
          end
        end
      end

      context "when token is incorrect" do
        let(:token) { subscription.id }

        it "raises an error" do
          expect { result }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when token has extra data" do
        let(:token) do
          expires = Time.current + 2.days
          token_values = { id: subscription.id, expires: expires }
          Subscription.encryptor.encrypt_and_sign(token_values)
        end

        it "finds by token" do
          expect(result).to eq(subscription)
        end
      end
    end
  end

  describe "create_alert_run" do
    let(:subscription) { create(:subscription, frequency: :daily) }

    it "creates a run" do
      subscription.create_alert_run

      expect(subscription.alert_runs.count).to eq(1)
      expect(subscription.alert_runs.first.run_on).to eq(Date.current)
    end

    context "if a run exists for today" do
      let!(:alert_run) { subscription.alert_runs.create(run_on: Date.current) }

      it "does not create another run" do
        subscription.create_alert_run

        expect(subscription.alert_runs.count).to eq(1)
        expect(subscription.alert_runs.first.id).to eq(alert_run.id)
      end
    end
  end

  describe "#vacancies_matching" do
    let(:vacancies) { subscription.vacancies_matching(default_scope) }
    let(:default_scope) { Vacancy.includes(:organisations).live.order(publish_on: :desc) }

    context "with vacancies" do
      before do
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/polygons.yml")).map(&:attributes).each { |s| LocationPolygon.create!(s) }
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/liverpool_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/basildon_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
        create(:vacancy, :published_slugged, slug: "liv", contact_number: "0", organisations: [liverpool_school], job_roles: %w[headteacher], visa_sponsorship_available: false, ect_status: :ect_unsuitable, subjects: %w[German], phases: %w[secondary], working_patterns: %w[full_time])
        create(:vacancy, :published_slugged, slug: "bas", contact_number: "1", organisations: [basildon_school], job_roles: %w[headteacher], phases: %w[secondary], subjects: nil, ect_status: :ect_unsuitable)
      end

      let(:liverpool_school) { School.find_by!(town: "Liverpool") }
      let(:basildon_school) { School.find_by!(town: "Basildon") }

      context "with keyword" do
        let(:subscription) { create(:daily_subscription, keyword: keyword) }
        let(:nice_job) { Vacancy.find_by!(contact_number: "9") }

        before do
          create(:vacancy, :published_slugged, contact_number: "9", job_title: "This is a Really Nice job", job_roles: %w[headteacher], phases: %w[secondary], working_patterns: %w[full_time])
        end

        context "with plain keyword" do
          let(:keyword) { "nice" }

          it "only finds the nice job" do
            expect(vacancies).to eq([nice_job])
          end
        end

        context "with multiple keywords" do
          let(:keyword) { "really nice" }

          it "finds the nice job" do
            expect(vacancies).to eq([nice_job])
          end
        end

        context "with keyword caps and trailing space" do
          let(:keyword) { "Nice " }

          it "only finds the nice job" do
            expect(vacancies).to eq([nice_job])
          end
        end
      end

      context "with location" do
        before do
          YAML.unsafe_load_file(Rails.root.join("spec/fixtures/st_albans_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
          create(:vacancy, :published_slugged, slug: "sta", contact_number: "2", organisations: [st_albans_school])
        end

        let(:st_albans_school) { School.find_by!(town: "St Albans") }
        let(:liverpool_vacancy) { Vacancy.find_by!(contact_number: "0") }
        let(:basildon_vacancy) { Vacancy.find_by!(contact_number: "1") }
        let(:st_albans_vacancy) { Vacancy.find_by!(contact_number: "2") }

        context "with nationwide location" do
          let(:subscription) { create(:daily_subscription, location: "england") }

          it "finds everything" do
            expect(vacancies.map(&:slug)).to contain_exactly(liverpool_vacancy.slug, basildon_vacancy.slug, st_albans_vacancy.slug)
          end
        end

        context "with a polygon (Basildon)" do
          let(:subscription) { create(:daily_subscription, location: "Basildon", radius: radius) }

          context "with a small radius" do
            let(:radius) { 4 }

            it "finds just basildon" do
              expect(vacancies.map(&:slug)).to eq([basildon_vacancy.slug])
            end
          end

          context "with a medium radius" do
            let(:radius) { 50 }

            it "finds basildon and st albans" do
              expect(vacancies.map(&:slug)).to contain_exactly(st_albans_vacancy.slug, basildon_vacancy.slug)
            end
          end

          context "with a large radius" do
            let(:radius) { 200 }

            it "finds liverpool as well" do
              expect(vacancies.map(&:slug)).to contain_exactly(liverpool_vacancy.slug, st_albans_vacancy.slug, basildon_vacancy.slug)
            end
          end
        end

        context "without a polygon (basildon postcode)", :geocode, :vcr do
          let(:subscription) { create(:daily_subscription, location: "Basildon SS14 3WB", radius: radius) }

          context "with a small radius" do
            let(:radius) { 4 }

            it "finds just basildon" do
              expect(vacancies.map(&:slug)).to eq([basildon_vacancy.slug])
            end
          end

          context "with a medium radius" do
            let(:radius) { 50 }

            it "finds basildon and st albans" do
              expect(vacancies.map(&:slug)).to contain_exactly(st_albans_vacancy.slug, basildon_vacancy.slug)
            end
          end

          context "with a large radius" do
            let(:radius) { 200 }

            it "finds liverpool as well" do
              expect(vacancies).to contain_exactly(liverpool_vacancy, st_albans_vacancy, basildon_vacancy)
            end
          end
        end

        context "when polygon has invalid geometry", :geocode do
          let(:subscription) { create(:daily_subscription, location: "basildon", radius: radius) }
          let(:radius) { 200 }

          before do
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(LocationPolygon).to receive(:area).and_raise(RGeo::Error::InvalidGeometry)
            # rubocop:enable RSpec/AnyInstance

            # Mock Geocoder to prevent real API call
            allow(Geocoder).to receive(:coordinates).with("basildon", hash_including(lookup: :google, components: "country:gb"))
                                                    .and_return([51.5761, 0.4886])
          end

          it "rescues RGeo::Error::InvalidGeometry and falls back to distance-based filtering" do
            expect(Sentry).to receive(:capture_exception).with(instance_of(RGeo::Error::InvalidGeometry))
            # same result as entering basildon postcode with radius of 200.
            expect(vacancies).to contain_exactly(liverpool_vacancy, st_albans_vacancy, basildon_vacancy)
          end
        end
      end

      context "with teaching job roles" do
        before do
          create(:vacancy, :published_slugged, contact_number: "teach1", job_roles: %w[teacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
          create(:vacancy, :published_slugged, contact_number: "itsupp1", job_roles: %w[it_support], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:teacher_vacancy) { Vacancy.find_by!(contact_number: "teach1") }
        let(:it_vacancy) { Vacancy.find_by!(contact_number: "itsupp1") }

        context "with single filter" do
          let(:subscription) { create(:subscription, teaching_job_roles: %w[teacher], frequency: :daily) }

          it "only finds the teaching job" do
            expect(vacancies).to eq([teacher_vacancy])
          end
        end

        context "with multiple filters" do
          let(:subscription) { create(:subscription, teaching_job_roles: %w[teacher], support_job_roles: %w[it_support], frequency: :daily) }

          it "finds both jobs" do
            expect(vacancies).to contain_exactly(teacher_vacancy, it_vacancy)
          end
        end
      end

      context "with support job roles" do
        before do
          create(:vacancy, :published_slugged, contact_number: "2", job_roles: %w[it_support], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:support_vacancy) { Vacancy.find_by!(contact_number: "2") }
        let(:subscription) { create(:subscription, support_job_roles: %w[it_support], frequency: :daily) }

        it "only finds the support job" do
          expect(vacancies).to eq([support_vacancy])
        end
      end

      context "with visa sponsorship" do
        before do
          create(:vacancy, :published_slugged, contact_number: "3", visa_sponsorship_available: true, job_roles: %w[headteacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:visa_job) { Vacancy.find_by!(contact_number: "3") }
        let(:subscription) { create(:subscription, :visa_sponsorship_required, frequency: :daily) }

        it "only finds the visa job" do
          expect(vacancies).to eq([visa_job])
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
          expect(vacancies).to eq([ect_job])
        end
      end

      context "with subjects filter" do
        before do
          create(:vacancy, :published_slugged, contact_number: "5", job_roles: %w[headteacher], subjects: %w[French], phases: %w[secondary], working_patterns: %w[full_time])
        end

        let(:french_job) { Vacancy.find_by!(contact_number: "5") }
        let(:subscription) { create(:subscription, subjects: %w[French], frequency: :daily) }

        it "only finds the French job" do
          expect(vacancies).to eq([french_job])
        end
      end

      context "with phases filter" do
        before do
          create(:vacancy, :published_slugged, contact_number: "6", job_roles: %w[headteacher], phases: %w[primary], working_patterns: %w[full_time])
        end

        let(:subscription) { create(:subscription, phases: %w[primary], frequency: :daily) }
        let(:primary_job) { Vacancy.find_by!(contact_number: "6") }

        it "only finds the primary school job" do
          expect(vacancies).to eq([primary_job])
        end
      end

      context "with working patterns filter" do
        before do
          create(:vacancy, :published_slugged, contact_number: "7", job_roles: %w[headteacher], phases: %w[secondary], is_job_share: false, working_patterns: %w[part_time])
          create(:vacancy, :published_slugged, contact_number: "8ft", job_roles: %w[headteacher], phases: %w[secondary], is_job_share: false, working_patterns: %w[full_time])
          create(:vacancy, :published_slugged, contact_number: "9js", job_roles: %w[headteacher], phases: %w[secondary], is_job_share: true, working_patterns: [])
        end

        let(:subscription) { create(:daily_subscription, working_patterns: %w[part_time job_share]) }
        let(:part_time_job) { Vacancy.find_by!(contact_number: "7") }
        let(:share_job) { Vacancy.find_by!(contact_number: "9js") }

        it "finds the part_time and job share jobs" do
          expect(vacancies.map(&:contact_number)).to contain_exactly(part_time_job.contact_number, share_job.contact_number)
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
          expect(vacancies).to eq([new_org_job])
        end
      end
    end

    context "with old and new vacancies" do
      before do
        create(:vacancy, :published_slugged, contact_number: "2", publish_on: Date.current)
        create(:vacancy, :published_slugged, contact_number: "1", publish_on: 1.day.ago)
      end

      let(:expected_vacancies) { [Vacancy.find_by!(contact_number: "2"), Vacancy.find_by!(contact_number: "1")] }
      let(:subscription) { create(:daily_subscription) }

      it "sends the vacancies in publish order descending" do
        expect(vacancies).to eq(expected_vacancies)
      end
    end
  end
end
