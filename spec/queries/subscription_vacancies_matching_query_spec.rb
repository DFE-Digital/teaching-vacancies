require "rails_helper"

RSpec.describe SubscriptionVacanciesMatchingQuery do
  describe "#call" do
    subject(:query_results) { described_class.new(scope: scope, subscription: subscription, limit: limit).call }

    let(:subscription) { nil }
    let(:scope) { Vacancy.all }
    let(:limit) { nil }

    describe "job roles matching" do
      let(:subscription) { create(:daily_subscription, teaching_job_roles: subscription_teaching_job_roles) }

      let!(:headteacher_job) { create(:vacancy, :published_slugged, :secondary, job_title: "Headteacher job", job_roles: %w[headteacher], working_patterns: %w[full_time]) }
      let!(:it_support_job) { create(:vacancy, :published_slugged, :secondary, job_title: "IT Support job", job_roles: %w[it_support], working_patterns: %w[full_time]) }
      let!(:teacher_and_other_support_job) do
        create(:vacancy, :published_slugged, :secondary, job_title: "Teacher and other support job", job_roles: %w[teacher other_support], working_patterns: %w[full_time])
      end

      context "with a single job role in the subscription filter" do
        let(:subscription_teaching_job_roles) { %w[teacher] }

        it "finds the vacancy matching the subscription job role" do
          expect(query_results).to contain_exactly(teacher_and_other_support_job.id)
        end
      end

      context "with multiple job roles in the subscription filter" do
        let(:subscription_teaching_job_roles) { %w[headteacher teacher] }

        it "finds all the vacancies matching any of the subscription job roles" do
          expect(query_results).to contain_exactly(headteacher_job.id, teacher_and_other_support_job.id)
        end
      end

      context "with the filter present but no job roles" do
        let(:subscription_teaching_job_roles) { [] }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end

      context "with no criteria for teaching job roles" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results)
            .to contain_exactly(headteacher_job.id, teacher_and_other_support_job.id, it_support_job.id)
        end
      end

      context "with a subscription having support job roles filter" do
        let(:subscription) { create(:daily_subscription, support_job_roles: %w[it_support]) }

        it "finds the support job role vacancy" do
          expect(query_results).to contain_exactly(it_support_job.id)
        end
      end

      context "with a subscription having both teaching and support job roles filter" do
        let(:subscription) { create(:daily_subscription, teaching_job_roles: %w[teacher], support_job_roles: %w[it_support]) }

        it "finds both the teaching and support job role vacancies" do
          expect(query_results).to contain_exactly(teacher_and_other_support_job.id, it_support_job.id)
        end
      end

      context "with a subscription with both teaching and support roles matching a single vacancy" do
        let(:subscription) { create(:daily_subscription, teaching_job_roles: %w[teacher], support_job_roles: %w[other_support]) }

        it "finds the vacancy matching both the teaching and support job roles" do
          expect(query_results).to contain_exactly(teacher_and_other_support_job.id)
        end
      end

      context "with a subscription having teaching and support job roles filter but no matching vacancies for either" do
        let(:subscription) { create(:daily_subscription, teaching_job_roles: %w[sendco], support_job_roles: %w[pastoral_health_and_welfare]) }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end

      context "with a subscription having teaching and support job roles filter but no matching vacancies for one of the filters" do
        let(:subscription) { create(:daily_subscription, teaching_job_roles: %w[headteacher], support_job_roles: %w[pastoral_health_and_welfare]) }

        it "finds the vacancies matching the other filter" do
          expect(query_results).to contain_exactly(headteacher_job.id)
        end
      end
    end

    describe "visa sponsorship matching" do
      let(:subscription) { create(:daily_subscription, visa_sponsorship_availability: true) }

      let!(:visa_sponsorship_job) do
        create(:vacancy, :published_slugged, job_title: "Visa sponsorship job", visa_sponsorship_available: true)
      end

      let!(:non_visa_sponsorship_job) do
        create(:vacancy, :published_slugged, job_title: "Non-visa sponsorship job", visa_sponsorship_available: false)
      end

      context "when the subscription requires visa sponsorship" do
        it "finds only the vacancies that offer visa sponsorship" do
          expect(query_results).to contain_exactly(visa_sponsorship_job.id)
        end
      end

      context "when the subscription does not require visa sponsorship" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results).to contain_exactly(visa_sponsorship_job.id, non_visa_sponsorship_job.id)
        end
      end
    end

    describe "ECT status matching" do
      let(:subscription) { create(:daily_subscription, ect_status: ect_status) }

      let!(:ect_job) { create(:vacancy, :published_slugged, job_title: "ECT job", ect_status: "ect_suitable") }
      let!(:non_ect_job) { create(:vacancy, :published_slugged, job_title: "Non-ECT job", ect_status: "ect_unsuitable") }

      context "when the subscription filters for suitability for Early Career Teachers" do
        let(:subscription) { create(:daily_subscription, ect_statuses: %w[ect_suitable]) }

        it "finds only the vacancies that suitable for ECT" do
          expect(query_results).to contain_exactly(ect_job.id)
        end
      end

      context "when the subscription does not filter for ECT suitability" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results).to contain_exactly(ect_job.id, non_ect_job.id)
        end
      end
    end

    describe "newly qualified teacher matching" do
      let(:subscription) { create(:daily_subscription, newly_qualified_teacher: newly_qualified_teacher) }

      let!(:ect_suitable_job) { create(:vacancy, :published_slugged, job_title: "ECT suitable job", ect_status: "ect_suitable") }
      let!(:ect_unsuitable_job) { create(:vacancy, :published_slugged, job_title: "ECT unsuitable job", ect_status: "ect_unsuitable") }

      context "when the subscription filters for newly qualified teachers" do
        let(:newly_qualified_teacher) { "true" }

        it "finds only the vacancies that are suitable for ECT" do
          expect(query_results).to contain_exactly(ect_suitable_job.id)
        end
      end

      context "when the subscription does not filter for newly qualified teachers" do
        let(:newly_qualified_teacher) { "false" }

        it "finds all the vacancies" do
          expect(query_results).to contain_exactly(ect_suitable_job.id, ect_unsuitable_job.id)
        end
      end

      context "when the subscriptions has no filter for newly qualified teachers" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results).to contain_exactly(ect_suitable_job.id, ect_unsuitable_job.id)
        end
      end
    end

    describe "subjects matching" do
      let(:subscription) { create(:daily_subscription, subjects: subscription_subjects) }

      let!(:french_job) { create(:vacancy, :published_slugged, :secondary, job_title: "French job", subjects: %w[French]) }
      let!(:german_job) { create(:vacancy, :published_slugged, :secondary, job_title: "German job", subjects: %w[German]) }
      let!(:maths_and_english_job) { create(:vacancy, :published_slugged, :secondary, job_title: "Maths and English job", subjects: %w[Maths English]) }
      let!(:no_subject_job) { create(:vacancy, :published_slugged, :secondary, job_title: "No subject job", subjects: nil) }

      context "with a single subject in the subscription filter" do
        let(:subscription_subjects) { %w[French] }

        it "finds the vacancy matching the subscription subject" do
          expect(query_results).to contain_exactly(french_job.id)
        end
      end

      context "with multiple subjects in the subscription filter" do
        let(:subscription_subjects) { %w[French German] }

        it "finds all the vacancies matching any of the subscription subjects" do
          expect(query_results).to contain_exactly(french_job.id, german_job.id)
        end
      end

      context "with the filter present but no subjects" do
        let(:subscription_subjects) { [] }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end

      context "with no criteria for subjects" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results)
            .to contain_exactly(french_job.id, german_job.id, maths_and_english_job.id, no_subject_job.id)
        end
      end

      context "with legacy single subject filter" do
        let(:subscription) { create(:daily_subscription, subject: "French") }

        it "finds the vacancy matching the subscription subject" do
          expect(query_results).to contain_exactly(french_job.id)
        end
      end

      context "with legacy single subject filter empty" do
        let(:subscription) { create(:daily_subscription, subject: "") }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end
    end

    describe "phases matching" do
      let(:subscription) { create(:daily_subscription, phases: subscription_phases) }

      let!(:primary_job) { create(:vacancy, :published_slugged, job_title: "Primary job", phases: %w[primary]) }
      let!(:secondary_job) { create(:vacancy, :published_slugged, job_title: "Secondary job", phases: %w[secondary]) }
      let!(:primary_and_secondary_job) { create(:vacancy, :published_slugged, job_title: "Primary and Secondary job", phases: %w[primary secondary]) }
      let!(:nursery_job) { create(:vacancy, :published_slugged, job_title: "Nursery job", phases: %w[nursery]) }

      context "with a single phase in the subscription filter" do
        let(:subscription_phases) { %w[primary] }

        it "finds all the vacancies matching the subscription phase" do
          expect(query_results).to contain_exactly(primary_job.id, primary_and_secondary_job.id)
        end
      end

      context "with multiple phases in the subscription filter" do
        let(:subscription_phases) { %w[primary secondary] }

        it "finds all the vacancies matching any of the subscription phases" do
          expect(query_results).to contain_exactly(primary_job.id, secondary_job.id, primary_and_secondary_job.id)
        end
      end

      context "with the filter present but no phases" do
        let(:subscription_phases) { [] }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end

      context "with no criteria for phases" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results)
            .to contain_exactly(primary_job.id, secondary_job.id, primary_and_secondary_job.id, nursery_job.id)
        end
      end
    end

    describe "working patterns matching" do
      let(:subscription) { create(:daily_subscription, working_patterns: subscription_working_patterns) }

      let!(:full_time_job) { create(:vacancy, :published_slugged, job_title: "Full time job", working_patterns: %w[full_time]) }
      let!(:part_time_job) { create(:vacancy, :published_slugged, job_title: "Part time job", working_patterns: %w[part_time]) }
      let!(:full_and_part_time_job) { create(:vacancy, :published_slugged, job_title: "Full and Part time job", working_patterns: %w[full_time part_time]) }
      let!(:job_share_job) { create(:vacancy, :published_slugged, job_title: "Job share job", is_job_share: true, working_patterns: %w[part_time]) }

      context "with a single working pattern in the subscription filter" do
        let(:subscription_working_patterns) { %w[full_time] }

        it "finds the vacancies matching the subscription working pattern" do
          expect(query_results).to contain_exactly(full_time_job.id, full_and_part_time_job.id)
        end
      end

      context "with multiple working patterns in the subscription filter" do
        let(:subscription_working_patterns) { %w[full_time part_time] }

        it "finds all the vacancies matching any of the subscription working patterns" do
          expect(query_results)
            .to contain_exactly(full_time_job.id, part_time_job.id, full_and_part_time_job.id, job_share_job.id)
        end
      end

      context "with job_share as the only working pattern in the subscription filter" do
        let(:subscription_working_patterns) { %w[job_share] }

        it "finds only the vacancies that are job share" do
          expect(query_results).to contain_exactly(job_share_job.id)
        end
      end

      context "with job_share and other working patterns in the subscription filter" do
        let(:subscription_working_patterns) { %w[job_share part_time] }

        it "finds the vacancies that are job share or match any of the other working patterns" do
          expect(query_results)
            .to contain_exactly(part_time_job.id, full_and_part_time_job.id, job_share_job.id)
        end
      end

      context "with the filter present but no working patterns" do
        let(:subscription_working_patterns) { [] }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end

      context "with no criteria for working patterns" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results)
            .to contain_exactly(full_time_job.id, part_time_job.id, full_and_part_time_job.id, job_share_job.id)
        end
      end
    end

    describe "organisation slug matching" do
      let(:subscription) { create(:daily_subscription, organisation_slug: organisation_slug) }

      let(:fantastic_school) { create(:school, name: "The Fantastic School", slug: "the-fantastic-school") }
      let(:great_school) { create(:school, name: "The Great School", slug: "the-great-school") }
      let!(:fantastic_job) { create(:vacancy, :published_slugged, organisations: [fantastic_school]) }
      let!(:great_job) { create(:vacancy, :published_slugged, organisations: [great_school]) }

      context "when the subscription filters for a specific organisation slug" do
        let(:organisation_slug) { "the-fantastic-school" }

        it "finds only the vacancies for that organisation" do
          expect(query_results).to contain_exactly(fantastic_job.id)
        end
      end

      context "when the subscription filters for a non-matching organisation slug" do
        let(:organisation_slug) { "fantastic-school" }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end

      context "when the subscription does not filter for an organisation slug" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results).to contain_exactly(fantastic_job.id, great_job.id)
        end
      end
    end

    describe "keyword matching" do
      let(:subscription) { create(:daily_subscription, keyword: keyword) }

      let!(:really_nice_job) { create(:vacancy, :published_slugged, :secondary, job_title: "This is a Really Nice job", job_roles: %w[headteacher], working_patterns: %w[full_time]) }
      let!(:nice_job) { create(:vacancy, :published_slugged, :secondary, job_title: "This is a nice job", job_roles: %w[headteacher], working_patterns: %w[full_time]) }

      before do
        create(:vacancy, :published_slugged, :secondary, job_title: "This is a job", job_roles: %w[headteacher], working_patterns: %w[full_time])
      end

      context "with a single keyword" do
        let(:keyword) { "nice" }

        it "finds all the vacancies matching the keyword" do
          expect(query_results).to contain_exactly(nice_job.id, really_nice_job.id)
        end
      end

      context "with multiple keywords" do
        let(:keyword) { "really nice" }

        it "only finds the vacancy matching all the keywords" do
          expect(query_results).to contain_exactly(really_nice_job.id)
        end
      end

      context "with keyword caps and trailing space" do
        let(:keyword) { "Nice " }

        it "finds all the vacancies matching the keyword without case/space sensitivity" do
          expect(query_results).to contain_exactly(nice_job.id, really_nice_job.id)
        end
      end

      context "with no keywords" do
        let(:keyword) { "" }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end
    end

    describe "location matching" do
      let(:subscription) { create(:daily_subscription, location: location, radius: radius) }

      let(:liverpool_school) { School.find_by!(town: "Liverpool") }
      let(:basildon_school) { School.find_by!(town: "Basildon") }
      let(:st_albans_school) { School.find_by!(town: "St Albans") }

      let(:liverpool_vacancy) { create(:vacancy, :published_slugged, slug: "liv", organisations: [liverpool_school]) }
      let(:basildon_vacancy) { create(:vacancy, :published_slugged, slug: "bas", organisations: [basildon_school]) }
      let(:st_albans_vacancy) { create(:vacancy, :published_slugged, slug: "sta", organisations: [st_albans_school]) }

      before do
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/polygons.yml")).map(&:attributes).each { |s| LocationPolygon.create!(s) }
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/liverpool_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/basildon_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/st_albans_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
        liverpool_vacancy
        basildon_vacancy
        st_albans_vacancy
      end

      context "with a subscription containing a nationwide location" do
        let(:subscription) { create(:daily_subscription, location: "england") }

        it "finds all the vacancies regardless their location" do
          expect(query_results).to contain_exactly(liverpool_vacancy.id, basildon_vacancy.id, st_albans_vacancy.id)
        end
      end

      context "with a subscription containing a polygon area (Basildon)" do
        let(:subscription) { create(:daily_subscription, location: "Basildon", radius: radius) }

        before do
          subscription.set_location_data!
        end

        context "with a small radius" do
          let(:radius) { 4 }

          it "finds just basildon vacancy" do
            expect(query_results).to contain_exactly(basildon_vacancy.id)
          end
        end

        context "with a medium radius" do
          let(:radius) { 50 }

          it "finds basildon and st albans vacancies" do
            expect(query_results).to contain_exactly(st_albans_vacancy.id, basildon_vacancy.id)
          end
        end

        context "with a large radius" do
          let(:radius) { 200 }

          it "finds all vacancies" do
            expect(query_results).to contain_exactly(liverpool_vacancy.id, st_albans_vacancy.id, basildon_vacancy.id)
          end
        end

        context "when the vacancy does not match the non-location criteria" do
          let(:subscription) do
            create(:daily_subscription, location: "Basildon", teaching_job_roles: %w[sendco], radius: 200)
          end

          it "does not find the vacancy" do
            expect(query_results).to be_empty
          end
        end

        context "when the vacancy belongs to multiple organisations matching the location filter" do
          let(:subscription) { create(:daily_subscription, location: "Basildon", radius: 50).tap(&:set_location_data!) }

          let(:basildon_vacancy) do
            create(:vacancy, :published_slugged, slug: "bas-sta", organisations: [basildon_school, st_albans_school])
          end

          it "returns the vacancy once" do
            expect(query_results).to contain_exactly(basildon_vacancy.id, st_albans_vacancy.id)
          end
        end
      end

      context "with a subscription containing a geopoint (basildon postcode)" do
        let(:subscription) { create(:daily_subscription, location: "Basildon SS14 3WB", radius: radius) }
        let(:geocoding_for_basildon) { instance_double(Geocoding, coordinates: [51.58521140000001, 0.4631542]) }

        before do
          allow(Geocoding).to receive(:new).and_return(geocoding_for_basildon)
          subscription.set_location_data!
        end

        context "with a small radius" do
          let(:radius) { 5 }

          it "finds just basildon vacancy" do
            expect(query_results).to contain_exactly(basildon_vacancy.id)
          end
        end

        context "with a medium radius" do
          let(:radius) { 50 }

          it "finds basildon and st albans vacancies" do
            expect(query_results).to contain_exactly(st_albans_vacancy.id, basildon_vacancy.id)
          end
        end

        context "with a large radius" do
          let(:radius) { 200 }

          it "finds all vacancies" do
            expect(query_results).to contain_exactly(liverpool_vacancy.id, st_albans_vacancy.id, basildon_vacancy.id)
          end
        end

        context "when the vacancy does not match the non-location criteria" do
          let(:subscription) do
            create(:daily_subscription, location: "Basildon SS14 3WB", teaching_job_roles: %w[pastoral_health_and_welfare], radius: 200)
          end

          it "does not find the vacancy" do
            expect(query_results).to be_empty
          end
        end

        context "when the vacancy belongs to multiple organisations matching the location filter" do
          let(:subscription) { create(:daily_subscription, location: "Basildon SS14 3WB", radius: 50) }

          let(:basildon_vacancy) do
            create(:vacancy, :published_slugged, slug: "bas-sta", organisations: [basildon_school, st_albans_school])
          end

          it "returns the vacancy once" do
            expect(query_results).to contain_exactly(basildon_vacancy.id, st_albans_vacancy.id)
          end
        end
      end

      context "with a subscription containing location search criteria but neither a polygon area nor a geopoint" do
        let(:subscription) { create(:daily_subscription, location: "Basildon", radius: radius) }
        let(:radius) { 50 }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end

      context "with a subscription containing no location search criteria" do
        let(:subscription) { create(:daily_subscription) }

        it "finds all the vacancies regardless their location" do
          expect(query_results).to contain_exactly(liverpool_vacancy.id, basildon_vacancy.id, st_albans_vacancy.id)
        end
      end

      context "with a subscription containing blanks search criteria" do
        let(:subscription) { create(:daily_subscription, location: "", radius: 10) }

        it "filters out all the vacancies" do
          expect(query_results).to be_empty
        end
      end
    end

    describe "combined criteria matching" do
      let(:subscription) do
        create(
          :daily_subscription,
          teaching_job_roles: %w[teacher],
          subjects: %w[French],
          phases: %w[secondary],
          working_patterns: %w[full_time],
          location: "england",
          radius: 0,
          keyword: "nice",
        )
      end

      let!(:matching_job) do
        create(:vacancy, :published_slugged, :secondary, job_title: "This is a nice French teacher job", job_roles: %w[teacher], subjects: %w[French], working_patterns: %w[full_time])
      end

      before do
        create(:vacancy, :published_slugged, :secondary, job_title: "This is a nice French headteacher job", job_roles: %w[headteacher], subjects: %w[French], working_patterns: %w[full_time])
        create(:vacancy, :published_slugged, :secondary, job_title: "This is a nice German teacher job", job_roles: %w[teacher], subjects: %w[German], working_patterns: %w[full_time])
        create(:vacancy, :published_slugged, phases: %w[primary], job_title: "This is a nice French teacher job", job_roles: %w[teacher], subjects: %w[French], working_patterns: %w[full_time])
        create(:vacancy, :published_slugged, :secondary, job_title: "This is a nice French teacher job", job_roles: %w[teacher], subjects: %w[French], working_patterns: %w[part_time])
        create(:vacancy, :published_slugged, :secondary, job_title: "This is a French teacher job", job_roles: %w[teacher], subjects: %w[French], working_patterns: %w[full_time])
      end

      it "only returns the vacancies matching all the criteria" do
        expect(query_results).to contain_exactly(matching_job.id)
      end
    end

    describe "limiting and ordering results" do
      let(:subscription) { create(:daily_subscription, keyword: "Job") }

      let!(:new_job) { create(:vacancy, :published_slugged, job_title: "New Job", publish_on: 3.days.ago) }
      let!(:newer_job) { create(:vacancy, :published_slugged, job_title: "Newer Job", publish_on: 2.days.ago) }
      let!(:older_job) { create(:vacancy, :published_slugged, job_title: "Older Job", publish_on: 4.days.ago) }

      context "when a limit is specified" do
        let(:limit) { 2 }

        it "returns only up to the specified number of matching vacancies keeping the most recent ones" do
          expect(query_results).to eq([newer_job.id, new_job.id])
        end
      end

      context "when a limit greater than the number of matching vacancies is specified" do
        let(:limit) { 5 }

        it "returns all the matching vacanciesordered by publish_on descending" do
          expect(query_results).to eq([newer_job.id, new_job.id, older_job.id])
        end
      end

      context "when no limit is specified" do
        let(:limit) { nil }

        it "returns all the matching vacanciesordered by publish_on descending" do
          expect(query_results).to eq([newer_job.id, new_job.id, older_job.id])
        end
      end
    end
  end
end
