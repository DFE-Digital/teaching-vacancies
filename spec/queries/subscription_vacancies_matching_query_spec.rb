require "rails_helper"

RSpec.describe SubscriptionVacanciesMatchingQuery do
  subject(:query_results) { described_class.call(scope: scope, subscription: subscription, limit: limit).map(&:job_title) }

  let(:subscription) { nil }
  let(:scope) { Vacancy.all }
  let(:limit) { nil }

  describe "#call" do
    let(:headteacher_job) { Vacancy.find_by!(job_title: "Headteacher job") }
    let(:it_support_job) { Vacancy.find_by!(job_title: "IT Support job") }
    let(:teacher_and_other_support_job) { Vacancy.find_by!(job_title: "Teacher and other support job") }
    let(:visa_sponsorship_job) { Vacancy.find_by(job_title: "Visa sponsorship job") }

    let(:non_visa_sponsorship_job) { Vacancy.find_by(job_title: "Non-visa sponsorship job") }
    let(:non_ect_job) { Vacancy.find_by!(job_title: "Non-ECT job") }

    let(:french_job) { Vacancy.find_by!(job_title: "French job") }
    let(:german_job) { Vacancy.find_by!(job_title: "German job") }
    let(:maths_and_english_job) { Vacancy.find_by!(job_title: "Maths and English job") }
    let(:no_subject_job) { Vacancy.find_by!(job_title: "No subject job", subjects: nil) }
    let(:through_job) { Vacancy.find_by!(job_title: "Through job") }
    let(:secondary_job) { Vacancy.find_by!(job_title: "Secondary job") }
    let(:primary_and_secondary_job) { Vacancy.find_by!(job_title: "Primary and Secondary job") }
    let(:nursery_job) { Vacancy.find_by!(job_title: "Nursery job") }
    let(:full_time_job) { Vacancy.find_by!(job_title: "Full time job") }
    let(:part_time_job) { Vacancy.find_by!(job_title: "Part time job") }
    let(:full_and_part_time_job) { Vacancy.find_by!(job_title: "Full and Part time job") }
    let(:job_share_job) { Vacancy.find_by!(job_title: "Job share job") }
    let(:fantastic_job) { Vacancy.find_by!(job_title: "Fantastic job") }
    let(:great_job) { Vacancy.find_by!(job_title: "Great job") }
    let(:really_nice_job) { Vacancy.find_by!(job_title: "This is a Really Nice job") }
    let(:nice_job) { Vacancy.find_by!(job_title: "This is a nice job") }

    # rubocop:disable RSpec/BeforeAfterAll
    before(:all) do
      school = create(:school)
      create(:vacancy, :published_slugged, :secondary, organisations: [school], job_title: "Headteacher job", job_roles: %w[headteacher administration_hr_data_and_finance], working_patterns: %w[full_time])
      create(:vacancy, :published_slugged, :secondary, organisations: [school], job_title: "IT Support job", job_roles: %w[it_support], working_patterns: %w[full_time])
      create(:vacancy, :published_slugged, :secondary, organisations: [school], job_title: "Teacher and other support job", job_roles: %w[deputy_headteacher other_support], working_patterns: %w[full_time])
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Visa sponsorship job", visa_sponsorship_available: true)

      create(:vacancy, :published_slugged, organisations: [school], job_title: "Non-visa sponsorship job", visa_sponsorship_available: false)
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Non-ECT job", ect_status: "ect_unsuitable")
      create(:vacancy, :published_slugged, :secondary, organisations: [school],  job_title: "French job", subjects: %w[French])
      create(:vacancy, :published_slugged, :secondary, organisations: [school],  job_title: "German job", subjects: %w[German])
      create(:vacancy, :published_slugged, :secondary, organisations: [school],  job_title: "Maths and English job", subjects: %w[Maths English])
      create(:vacancy, :published_slugged, :secondary, organisations: [school], job_title: "No subject job", subjects: nil)
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Through job", phases: %w[through])
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Secondary job", phases: %w[secondary])
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Primary and Secondary job", phases: %w[primary secondary])
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Nursery job", phases: %w[nursery])
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Full time job", working_patterns: %w[full_time])
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Part time job", working_patterns: %w[part_time])
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Full and Part time job", working_patterns: %w[full_time part_time])
      create(:vacancy, :published_slugged, organisations: [school], job_title: "Job share job", is_job_share: true, working_patterns: %w[part_time])
      fantastic_school = create(:school, name: "The Fantastic School", slug: "the-fantastic-school")
      great_school = create(:school, name: "The Great School", slug: "the-great-school")
      create(:vacancy, :published_slugged, job_title: "Fantastic job", organisations: [fantastic_school])
      create(:vacancy, :published_slugged, job_title: "Great job", organisations: [great_school])
      create(:vacancy, :published_slugged, :secondary, organisations: [school], job_title: "This is a Really Nice job")
      create(:vacancy, :published_slugged, :secondary, organisations: [school], job_title: "This is a nice job")
    end

    after(:all) do
      Vacancy.destroy_all
      School.destroy_all
      Publisher.destroy_all
      Subscription.destroy_all
    end
    # rubocop:enable RSpec/BeforeAfterAll

    describe "job roles matching" do
      let(:subscription) { build_stubbed(:daily_subscription, teaching_job_roles: subscription_teaching_job_roles) }

      context "with a single job role in the subscription filter" do
        let(:subscription_teaching_job_roles) { %w[other_support] }

        it "finds the vacancy matching the subscription job role" do
          expect(query_results).to contain_exactly(teacher_and_other_support_job.job_title)
        end
      end

      context "with multiple job roles in the subscription filter" do
        let(:subscription_teaching_job_roles) { %w[headteacher other_support] }

        it "finds all the vacancies matching any of the subscription job roles" do
          expect(query_results).to contain_exactly(headteacher_job.job_title, teacher_and_other_support_job.job_title)
        end
      end

      context "with the filter present but no job roles" do
        let(:subscription_teaching_job_roles) { [] }

        it "finds no vacancies" do
          pending("Is this correct behaviour?")

          expect(query_results).to be_empty
        end
      end

      context "with no criteria for teaching job roles" do
        let(:subscription) { build_stubbed(:daily_subscription) }

        it "finds all the vacancies" do
          expect(query_results)
            .to match_array([headteacher_job,
                             teacher_and_other_support_job,
                             it_support_job,
                             nice_job,
                             really_nice_job,
                             visa_sponsorship_job,
                             non_visa_sponsorship_job,
                             non_ect_job,
                             french_job,
                             fantastic_job,
                             great_job,
                             german_job,
                             maths_and_english_job,
                             nursery_job,
                             primary_and_secondary_job,
                             through_job,
                             secondary_job,
                             part_time_job,
                             full_and_part_time_job,
                             full_time_job,
                             job_share_job,
                             no_subject_job].map(&:job_title))
        end
      end

      context "with a subscription having support job roles filter" do
        let(:subscription) { build_stubbed(:daily_subscription, support_job_roles: %w[it_support]) }

        it "finds the support job role vacancy" do
          expect(query_results).to contain_exactly(it_support_job.job_title)
        end
      end

      context "with a subscription having both teaching and support job roles filter" do
        let(:subscription) { build_stubbed(:daily_subscription, teaching_job_roles: %w[deputy_headteacher], support_job_roles: %w[it_support]) }

        it "finds both the teaching and support job role vacancies" do
          expect(query_results).to contain_exactly(teacher_and_other_support_job.job_title, it_support_job.job_title)
        end
      end

      context "with a subscription with both teaching and support roles matching a single vacancy" do
        let(:subscription) { build_stubbed(:daily_subscription, teaching_job_roles: %w[headteacher], support_job_roles: %w[administration_hr_data_and_finance]) }

        it "finds the vacancy matching both the teaching and support job roles" do
          expect(query_results).to contain_exactly(headteacher_job.job_title)
        end
      end

      context "with a subscription having teaching and support job roles filter but no matching vacancies for either" do
        let(:subscription) { build_stubbed(:daily_subscription, teaching_job_roles: %w[sendco], support_job_roles: %w[pastoral_health_and_welfare]) }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end

      context "with a subscription having teaching and support job roles filter but no matching vacancies for one of the filters" do
        let(:subscription) { build_stubbed(:daily_subscription, teaching_job_roles: %w[headteacher], support_job_roles: %w[administration_hr_data_and_finance]) }

        it "finds the vacancies matching the other filter" do
          expect(query_results).to contain_exactly(headteacher_job.job_title)
        end
      end
    end

    describe "visa sponsorship matching" do
      let(:subscription) { build_stubbed(:daily_subscription, visa_sponsorship_availability: true) }

      it "finds only the vacancies that offer visa sponsorship" do
        expect(query_results).to contain_exactly(visa_sponsorship_job.job_title)
      end
    end

    describe "ECT status matching" do
      let(:subscription) { build_stubbed(:daily_subscription, ect_statuses: %w[ect_suitable]) }

      it "finds only the vacancies that suitable for ECT" do
        expect(query_results).not_to include(non_ect_job.job_title)
      end
    end

    describe "newly qualified teacher matching" do
      let(:subscription) { build_stubbed(:daily_subscription, newly_qualified_teacher: newly_qualified_teacher) }

      context "when the subscription filters for newly qualified teachers" do
        let(:newly_qualified_teacher) { "true" }

        it "finds only the vacancies that are suitable for ECT" do
          expect(query_results).not_to include(non_ect_job.job_title)
        end
      end

      context "when the subscription does not filter for newly qualified teachers" do
        let(:newly_qualified_teacher) { "false" }

        it "finds all the vacancies" do
          expect(query_results).to include(non_ect_job.job_title)
        end
      end
    end

    describe "subjects matching" do
      let(:subscription) { build_stubbed(:daily_subscription, subjects: subscription_subjects) }

      context "with a single subject in the subscription filter" do
        let(:subscription_subjects) { %w[French] }

        it "finds the vacancy matching the subscription subject" do
          expect(query_results).to contain_exactly(french_job.job_title)
        end
      end

      context "with multiple subjects in the subscription filter" do
        let(:subscription_subjects) { %w[French German] }

        it "finds all the vacancies matching any of the subscription subjects" do
          expect(query_results).to contain_exactly(french_job.job_title, german_job.job_title)
        end
      end

      context "with the filter present but no subjects" do
        let(:subscription_subjects) { [] }

        it "finds no vacancies" do
          pending("Is this correct behaviour?")

          expect(query_results).to be_empty
        end
      end

      context "with legacy single subject filter" do
        let(:subscription) { build_stubbed(:daily_subscription, subject: "French") }

        it "finds the vacancy matching the subscription subject" do
          expect(query_results).to contain_exactly(french_job.job_title)
        end
      end

      context "with legacy single subject filter empty" do
        let(:subscription) { build_stubbed(:daily_subscription, subject: "") }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end
    end

    describe "phases matching" do
      let(:subscription) { build_stubbed(:daily_subscription, phases: subscription_phases) }

      context "with a single phase in the subscription filter" do
        let(:subscription_phases) { %w[through] }

        it "finds all the vacancies matching the subscription phase" do
          expect(query_results).to contain_exactly(through_job.job_title)
        end
      end

      context "with multiple phases in the subscription filter" do
        let(:subscription_phases) { %w[through secondary] }

        it "finds all the vacancies matching any of the subscription phases" do
          expect(query_results).to match_array([through_job,
                                                secondary_job,
                                                primary_and_secondary_job,
                                                french_job,
                                                nice_job,
                                                really_nice_job,
                                                german_job,
                                                it_support_job,
                                                teacher_and_other_support_job,
                                                maths_and_english_job,
                                                no_subject_job,
                                                headteacher_job].map(&:job_title))
        end
      end

      context "with the filter present but no phases" do
        let(:subscription_phases) { [] }

        it "finds no vacancies" do
          pending("Is this correct behaviour?")

          expect(query_results).to be_empty
        end
      end
    end

    describe "working patterns matching" do
      let(:subscription) { build_stubbed(:daily_subscription, working_patterns: subscription_working_patterns) }

      context "with a single working pattern in the subscription filter" do
        let(:subscription_working_patterns) { %w[full_time] }

        it "finds the vacancies matching the subscription working pattern" do
          expect(query_results).to match_array([french_job,
                                                german_job,
                                                headteacher_job,
                                                it_support_job,
                                                maths_and_english_job,
                                                no_subject_job,
                                                non_ect_job,
                                                great_job,
                                                nice_job,
                                                really_nice_job,
                                                fantastic_job,
                                                non_visa_sponsorship_job,
                                                nursery_job,
                                                primary_and_secondary_job,
                                                secondary_job,
                                                full_time_job,
                                                through_job,
                                                teacher_and_other_support_job,
                                                visa_sponsorship_job,
                                                full_and_part_time_job].map(&:job_title))
        end
      end

      context "with multiple working patterns in the subscription filter" do
        let(:subscription_working_patterns) { %w[full_time part_time] }

        it "finds all the vacancies matching any of the subscription working patterns" do
          expect(query_results)
            .to match_array([french_job,
                             primary_and_secondary_job,
                             secondary_job,
                             teacher_and_other_support_job,
                             german_job,
                             nursery_job,
                             through_job,
                             nice_job,
                             really_nice_job,
                             visa_sponsorship_job,
                             great_job,
                             fantastic_job,
                             headteacher_job,
                             it_support_job,
                             no_subject_job,
                             non_ect_job,
                             non_visa_sponsorship_job,
                             maths_and_english_job,
                             full_time_job,
                             part_time_job,
                             full_and_part_time_job,
                             job_share_job].map(&:job_title))
        end
      end

      context "with job_share as the only working pattern in the subscription filter" do
        let(:subscription_working_patterns) { %w[job_share] }

        it "finds only the vacancies that are job share" do
          expect(query_results).to contain_exactly(job_share_job.job_title)
        end
      end

      context "with job_share and other working patterns in the subscription filter" do
        let(:subscription_working_patterns) { %w[job_share part_time] }

        it "finds the vacancies that are job share or match any of the other working patterns" do
          expect(query_results)
            .to contain_exactly(part_time_job.job_title, full_and_part_time_job.job_title, job_share_job.job_title)
        end
      end

      context "with the filter present but no working patterns" do
        let(:subscription_working_patterns) { [] }

        it "finds no vacancies" do
          pending("Is this correct behaviour?")
          expect(query_results).to be_empty
        end
      end
    end

    describe "organisation slug matching" do
      let(:subscription) { build_stubbed(:daily_subscription, organisation_slug: organisation_slug) }

      context "when the subscription filters for a specific organisation slug" do
        let(:organisation_slug) { "the-fantastic-school" }

        it "finds only the vacancies for that organisation" do
          expect(query_results).to contain_exactly(fantastic_job.job_title)
        end
      end

      context "when the subscription filters for a non-matching organisation slug" do
        let(:organisation_slug) { "fantastic-school" }

        it "finds no vacancies" do
          expect(query_results).to be_empty
        end
      end
    end

    describe "keyword matching" do
      let(:subscription) { build_stubbed(:daily_subscription, keyword: keyword) }

      context "with a single keyword" do
        let(:keyword) { "nice" }

        it "finds all the vacancies matching the keyword" do
          expect(query_results).to contain_exactly(nice_job.job_title, really_nice_job.job_title)
        end
      end

      context "with multiple keywords" do
        let(:keyword) { "really nice" }

        it "only finds the vacancy matching all the keywords" do
          expect(query_results).to contain_exactly(really_nice_job.job_title)
        end
      end

      context "with keyword caps and trailing space" do
        let(:keyword) { "Nice " }

        it "finds all the vacancies matching the keyword without case/space sensitivity" do
          expect(query_results).to contain_exactly(nice_job.job_title, really_nice_job.job_title)
        end
      end

      context "with no keywords" do
        let(:keyword) { "" }

        it "finds no vacancies" do
          pending("Is this correct behaviour?")

          expect(query_results).to be_empty
        end
      end
    end
  end

  describe "combined criteria matching" do
    let(:subscription) do
      build_stubbed(
        :daily_subscription,
        teaching_job_roles: %w[teacher],
        subjects: %w[French],
        phases: %w[secondary],
        working_patterns: %w[full_time],
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
      expect(query_results).to contain_exactly(matching_job.job_title)
    end
  end

  describe "limiting and ordering results" do
    let(:subscription) { build_stubbed(:daily_subscription, keyword: "Job") }

    let!(:new_job) { create(:vacancy, :published_slugged, job_title: "New Job", publish_on: 3.days.ago) }
    let!(:newer_job) { create(:vacancy, :published_slugged, job_title: "Newer Job", publish_on: 2.days.ago) }
    let!(:older_job) { create(:vacancy, :published_slugged, job_title: "Older Job", publish_on: 4.days.ago) }

    context "when a limit is specified" do
      let(:limit) { 2 }

      it "returns only up to the specified number of matching vacancies keeping the most recent ones" do
        expect(query_results).to eq([newer_job.job_title, new_job.job_title])
      end
    end

    context "when a limit greater than the number of matching vacancies is specified" do
      let(:limit) { 5 }

      it "returns all the matching vacanciesordered by publish_on descending" do
        expect(query_results).to eq([newer_job.job_title, new_job.job_title, older_job.job_title])
      end
    end

    context "when no limit is specified" do
      let(:limit) { nil }

      it "returns all the matching vacanciesordered by publish_on descending" do
        expect(query_results).to eq([newer_job.job_title, new_job.job_title, older_job.job_title])
      end
    end
  end
end
