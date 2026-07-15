require "rails_helper"

RSpec.describe "subscription location matching" do
  subject(:query_results) { SubscriptionVacanciesMatchingQuery.call(scope: scope, subscription: subscription, limit: limit).map(&:job_title) }

  let(:subscription) { nil }
  let(:scope) { Vacancy.all }
  let(:limit) { nil }

  let(:liverpool_vacancy) { Vacancy.find_by!(job_title: "liv") }
  let(:basildon_vacancy) { Vacancy.find_by!(job_title: "bas") }
  let(:st_albans_vacancy) { Vacancy.find_by!(job_title: "sta") }
  let(:basildon_stalbans_vacancy) { Vacancy.find_by!(job_title: "bas-sta") }

  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) do
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/polygons.yml")).map(&:attributes).each { |s| LocationPolygon.create!(s) }
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/liverpool_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/basildon_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/st_albans_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
    liverpool_org = School.find_by!(town: "Liverpool")
    basildon_org = School.find_by!(town: "Basildon")
    st_albans_org = School.find_by!(town: "St Albans")

    create(:vacancy, :published_slugged, job_title: "liv", organisations: [liverpool_org])
    create(:vacancy, :published_slugged, job_title: "bas", organisations: [basildon_org])
    create(:vacancy, :published_slugged, job_title: "sta", organisations: [st_albans_org])
    create(:vacancy, :published_slugged, job_title: "bas-sta", organisations: [basildon_org, st_albans_org])
  end

  after(:all) do
    Vacancy.destroy_all
    School.destroy_all
    Publisher.destroy_all
    Subscription.destroy_all
    LocationPolygon.destroy_all
  end
  # rubocop:enable RSpec/BeforeAfterAll

  context "with a subscription containing a nationwide location" do
    let(:subscription) { create(:daily_subscription, location: "england") }

    it "finds all the vacancies regardless their location" do
      expect(query_results).to match_array([liverpool_vacancy, basildon_vacancy, st_albans_vacancy, basildon_stalbans_vacancy].map(&:job_title))
    end
  end

  context "with a subscription containing a polygon area (Basildon)" do
    let(:subscription) { create(:daily_subscription, location: "Basildon", radius: radius).tap(&:set_location_data!) }

    context "with a small radius" do
      let(:radius) { 4 }

      it "finds just basildon vacancy" do
        expect(query_results).to contain_exactly(basildon_vacancy.job_title, basildon_stalbans_vacancy.job_title)
      end
    end

    context "with a medium radius" do
      let(:radius) { 50 }

      it "finds basildon and st albans vacancies" do
        expect(query_results).to contain_exactly(st_albans_vacancy.job_title, basildon_vacancy.job_title, basildon_stalbans_vacancy.job_title)
      end
    end

    context "with a large radius" do
      let(:radius) { 200 }

      it "finds all vacancies" do
        expect(query_results).to contain_exactly(liverpool_vacancy.job_title, st_albans_vacancy.job_title, basildon_vacancy.job_title, basildon_stalbans_vacancy.job_title)
      end
    end

    context "when the vacancy does not match the non-location criteria" do
      let(:subscription) { create(:daily_subscription, location: "Basildon", teaching_job_roles: %w[sendco], radius: 200) }

      it "does not find the vacancy" do
        expect(query_results).to be_empty
      end
    end

    context "when the vacancy belongs to multiple organisations matching the location filter" do
      let(:subscription) { create(:daily_subscription, location: "Basildon", radius: 50).tap(&:set_location_data!) }

      it "returns the vacancy once" do
        expect(query_results).to match_array([basildon_stalbans_vacancy, basildon_vacancy, st_albans_vacancy].map(&:job_title))
      end
    end
  end

  context "with a subscription containing a geopoint (basildon postcode)" do
    let(:subscription) { create(:daily_subscription, location: "Basildon SS14 3WB", radius: radius).tap(&:set_location_data!) }
    let(:geocoding_for_basildon) { instance_double(Geocoding, coordinates: [51.58521140000001, 0.4631542]) }

    before do
      allow(Geocoding).to receive(:new).and_return(geocoding_for_basildon)
    end

    context "with a small radius" do
      let(:radius) { 5 }

      it "finds just basildon vacancy" do
        expect(query_results).to contain_exactly(basildon_vacancy.job_title, basildon_stalbans_vacancy.job_title)
      end
    end

    context "with a 50 radius" do
      let(:radius) { 50 }

      it "finds basildon and st albans vacancies" do
        expect(query_results).to contain_exactly(st_albans_vacancy.job_title, basildon_vacancy.job_title, basildon_stalbans_vacancy.job_title)
      end
    end

    context "with a 200 radius" do
      let(:radius) { 200 }

      it "finds all vacancies" do
        expect(query_results).to match_array([liverpool_vacancy,
                                              st_albans_vacancy,
                                              basildon_stalbans_vacancy,
                                              basildon_vacancy].map(&:job_title))
      end
    end

    context "when the vacancy does not match the non-location criteria" do
      let(:subscription) { create(:daily_subscription, location: "Basildon SS14 3WB", teaching_job_roles: %w[pastoral_health_and_welfare], radius: 200) }

      it "does not find the vacancy" do
        expect(query_results).to be_empty
      end
    end

    context "when the vacancy does not match the non-location subjects" do
      let(:subscription) { create(:daily_subscription, location: "Basildon SS14 3WB", subjects: %w[French German], radius: 200) }

      it "does not find the vacancy" do
        expect(query_results).to be_empty
      end
    end

    context "when the vacancy belongs to multiple organisations matching the location filter" do
      let(:subscription) { create(:daily_subscription, location: "Basildon SS14 3WB", radius: 50).tap(&:set_location_data!) }

      it "returns the vacancy once" do
        expect(query_results).to match_array([basildon_vacancy, st_albans_vacancy, basildon_stalbans_vacancy].map(&:job_title))
      end
    end
  end

  context "with a subscription containing location search criteria but neither a polygon area nor a geopoint" do
    let(:subscription) { create(:daily_subscription, location: "Basildon", radius: radius) }
    let(:radius) { 50 }

    it "finds no vacancies" do
      pending("Is this correct behaviour?")

      expect(query_results).to be_empty
    end
  end

  context "with a subscription containing no location search criteria" do
    let(:subscription) { create(:daily_subscription) }

    it "finds all the vacancies regardless their location" do
      expect(query_results).to match_array([liverpool_vacancy, basildon_vacancy, st_albans_vacancy, basildon_stalbans_vacancy].map(&:job_title))
    end
  end

  context "with a subscription containing blanks search criteria" do
    let(:subscription) { create(:daily_subscription, location: "", radius: 10) }

    it "filters out all the vacancies" do
      pending("Is this correct behaviour?")

      expect(query_results).to be_empty
    end
  end
end
