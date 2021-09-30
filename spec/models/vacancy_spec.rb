require "rails_helper"

RSpec.describe Vacancy do
  it { is_expected.to belong_to(:publisher_organisation).optional }
  it { is_expected.to belong_to(:publisher).optional }
  it { is_expected.to have_many(:organisation_vacancies) }
  it { is_expected.to have_many(:organisations) }
  it { is_expected.to have_many(:saved_jobs) }
  it { is_expected.to have_many(:saved_by) }
  it { is_expected.to have_many(:job_applications) }
  it { is_expected.to have_one(:equal_opportunities_report) }

  describe "#has_noticed_notifications" do
    subject { create(:vacancy) }

    let(:job_application) { create(:job_application, vacancy: subject) }

    before do
      Publishers::JobApplicationReceivedNotification.with(vacancy: subject, job_application: job_application)
                                                    .deliver(subject.publisher)
      expect(Notification.count).to eq 1
      subject.destroy
    end

    it "removes the notification when destroyed" do
      expect(Notification.count).to eq 0
    end
  end

  context "indexing for search" do
    describe "#update_index!" do
      it { is_expected.to have_db_column(:initially_indexed) }
      it { is_expected.to have_db_index(:initially_indexed) }

      it "indexes `live` records where `initially_indexed == false`" do
        allow(described_class).to receive_message_chain(:unindexed, :update_all).with({ initially_indexed: true })
        expect(described_class).to receive_message_chain(:unindexed, :algolia_reindex!)
        described_class.update_index!
      end

      it "flags indexed records as `initially_indexed = true`" do
        allow(described_class).to receive_message_chain(:unindexed, :algolia_reindex!)
        expect(described_class).to receive_message_chain(:unindexed, :update_all).with({ initially_indexed: true })
        described_class.update_index!
      end
    end

    describe "#reindex!" do
      it "is overridden so that it only indexes vacancies scoped as `live`" do
        expect(described_class).to receive_message_chain(:live, :includes, :algolia_reindex!)
        described_class.reindex!
      end
    end

    describe "#reindex" do
      it "is overridden so that it only indexes vacancies scoped as `live`" do
        expect(described_class).to receive_message_chain(:live, :includes, :algolia_reindex)
        described_class.reindex
      end
    end

    describe "#remove_vacancies_that_expired_yesterday!" do
      it "selects all records that expired yesterday" do
        expect(described_class).to receive(:expired_yesterday)
        described_class.remove_vacancies_that_expired_yesterday!
      end

      it "calls .index.delete_objects on the expired records" do
        vacancy = double(Vacancy, id: "ABC123")
        allow(described_class).to receive(:expired_yesterday).and_return([vacancy])
        expect(described_class).to receive_message_chain(:index, :delete_objects).with(%w[ABC123])
        described_class.remove_vacancies_that_expired_yesterday!
      end
    end
  end

  describe "friendly_id generated slug" do
    describe "#slug" do
      it "the slug cannot be duplicate" do
        green_school = create(:school, name: "Green school", town: "Greenway", county: "Mars")
        blue_school = create(:school, name: "Blue school")

        first_maths_teacher = create(:vacancy, :published, job_title: "Maths Teacher",
                                                           organisation_vacancies_attributes: [{ organisation: blue_school }])
        second_maths_teacher = create(:vacancy, :published, job_title: "Maths Teacher",
                                                            organisation_vacancies_attributes: [{ organisation: green_school }])
        third_maths_teacher = create(:vacancy, :published, job_title: "Maths Teacher",
                                                           organisation_vacancies_attributes: [{ organisation: green_school }])
        fourth_maths_teacher = create(:vacancy, :published, job_title: "Maths Teacher",
                                                            organisation_vacancies_attributes: [{ organisation: green_school }])

        expect(first_maths_teacher.slug).to eq("maths-teacher")
        expect(second_maths_teacher.slug).to eq("maths-teacher-green-school")
        expect(third_maths_teacher.slug).to eq("maths-teacher-green-school-greenway-mars")

        expect(fourth_maths_teacher.slug).to include("maths-teacher")
        expect(fourth_maths_teacher.slug).not_to eq("maths-teacher")
        expect(fourth_maths_teacher.slug).not_to eq("maths-teacher-green-school")
        expect(fourth_maths_teacher.slug).not_to eq("maths-teacher-green-school-greenway-mars")
      end
    end

    describe "#refresh_slug" do
      it "resets the current slug by accessing a friendly_id private method" do
        job = create(:vacancy, slug: "the-wrong-slug")
        job.job_title = "CS Teacher"
        job.refresh_slug

        expect(job.slug).to eq("cs-teacher")
      end
    end

    describe "#listed?" do
      let(:datetime) do
        instance_double(DateTime)
      end

      subject do
        build(:vacancy, :published)
      end

      it "does not break if #expires_at is nil" do
        subject.expires_at = nil
        expect { subject.listed? }.not_to raise_error
      end

      it "checks #expires_at is in the future" do
        allow(subject).to receive(:expires_at).and_return(datetime)
        expect(datetime).to receive(:future?)
        subject.listed?
      end

      it "checks #published?" do
        expect(subject).to receive(:published?)
        subject.listed?
      end

      it 'checks if #published == "draft" (yields published? == false)' do
        subject.status = "draft"
        expect(subject.listed?).to be_falsey
      end

      describe "#publish_on" do
        before do
          allow(subject).to receive(:publish_on).and_return(datetime)
          allow(datetime).to receive(:past?)
          allow(datetime).to receive(:today?)
        end

        it "checks if #publish_on is in the past" do
          expect(datetime).to receive(:past?)
          subject.listed?
        end

        it "checks if #publish_on is today" do
          expect(datetime).to receive(:today?)
          subject.listed?
        end

        it "does not break if publish_on is nil" do
          subject.publish_on = nil
          expect { subject.listed? }.not_to raise_error
        end
      end

      it "return true if all the conditions are met" do
        expect(subject.listed?).to be_truthy
      end
    end
  end

  context "scopes" do
    let(:expired_earlier_today) { create(:vacancy, expires_at: 5.hour.ago) }
    let(:expires_later_today) { create(:vacancy, status: :published, expires_at: 1.hour.from_now) }

    describe "#active" do
      it "retrieves active vacancies that have a status of :draft or :published" do
        draft = create_list(:vacancy, 2, :draft)
        published = create_list(:vacancy, 5, :published)
        create_list(:vacancy, 4, :trashed)

        expect(Vacancy.active.count).to eq(draft.count + published.count)
      end
    end

    describe "#applicable" do
      it "finds current vacancies" do
        expired_earlier_today.send :set_slug
        expired_earlier_today.save(validate: false)

        results = Vacancy.applicable
        expect(results).to include(expires_later_today)
        expect(results).to_not include(expired_earlier_today)
      end
    end

    describe "#awaiting_feedback" do
      it "gets all vacancies awaiting feedback" do
        expired_and_awaiting = create_list(:vacancy, 2, :expired)
        create_list(:vacancy, 3, :expired, listed_elsewhere: :listed_paid, hired_status: :hired_tvs)
        create_list(:vacancy, 3, :published_slugged)

        expect(Vacancy.awaiting_feedback.count).to eq(expired_and_awaiting.count)
      end
    end

    describe "#expired" do
      it "retrieves published vacancies that have a past expires_at" do
        create_list(:vacancy, 5, :published)
        expired = build(:vacancy, expires_at: Time.current - 1.hour)
        expired.send :set_slug
        expired.save(validate: false)

        trashed_expired = build(:vacancy, expires_at: Time.current - 1.hour)
        trashed_expired.send :set_slug
        trashed_expired.save(validate: false)
        trashed_expired.trashed!

        expect(Vacancy.expired.count).to eq(1)
      end
    end

    describe "#expired_yesterday" do
      it "retrieves published and unpublished vacancies that have an expires_at of yesterday" do
        create(:vacancy, :published, :expired_yesterday)
        create(:vacancy, :draft, :expired_yesterday)
        create(:vacancy, :published, :expires_tomorrow)

        expect(Vacancy.expired_yesterday.count).to eq(2)
      end
    end

    describe "#expires_within_data_access_period" do
      let(:expired_years_ago) { build(:vacancy, expires_at: 2.years.ago) }

      it "retrieves vacancies that expired not more than one year ago" do
        expect(Vacancy.expires_within_data_access_period).to_not include(expired_years_ago)
        expect(Vacancy.expires_within_data_access_period).to include(expired_earlier_today)
      end
    end

    describe "#listed" do
      it "retrieves vacancies that have a status of :published and a past publish_on date" do
        published = create_list(:vacancy, 5, :published)
        create_list(:vacancy, 3, :future_publish)
        create_list(:vacancy, 4, :trashed)

        expect(Vacancy.listed.count).to eq(published.count)
      end
    end

    describe "#live" do
      it "includes vacancies till expiry time" do
        expect(Vacancy.live).to include(expires_later_today)
        expect(Vacancy.live).to_not include(expired_earlier_today)
      end
    end

    describe "#pending" do
      it "retrieves vacancies that have a status of :published, a future publish_on date & a future expires_at date" do
        create_list(:vacancy, 5, :published)
        pending = create_list(:vacancy, 3, :future_publish)

        expect(Vacancy.pending.count).to eq(pending.count)
      end
    end

    describe "#published_on_count(date)" do
      it "retrieves vacancies listed on the specified date" do
        published_today = create_list(:vacancy, 3, :published_slugged)
        published_yesterday = build_list(:vacancy, 2, :published_slugged, publish_on: 1.day.ago)
        published_yesterday.each { |v| v.save(validate: false) }
        published_the_other_day = build_list(:vacancy, 1, :published_slugged, publish_on: 2.days.ago)
        published_the_other_day.each { |v| v.save(validate: false) }
        published_some_other_day = build_list(:vacancy, 6, :published_slugged, publish_on: 1.month.ago)
        published_some_other_day.each { |v| v.save(validate: false) }

        expect(Vacancy.published_on_count(Date.current)).to eq(published_today.count)
        expect(Vacancy.published_on_count(1.day.ago)).to eq(published_yesterday.count)
        expect(Vacancy.published_on_count(2.days.ago)).to eq(published_the_other_day.count)
        expect(Vacancy.published_on_count(1.month.ago)).to eq(published_some_other_day.count)
      end
    end
  end

  describe "#parent_organisation_name" do
    context "when vacancy has a school" do
      it "returns the school name for the vacancy" do
        school = create(:school, name: "St James School")
        vacancy = create(:vacancy)
        vacancy.organisation_vacancies.create(organisation: school)

        expect(vacancy.parent_organisation_name).to eq(school.name)
      end
    end

    context "when vacancy has a school_group" do
      it "returns the school_group name for the vacancy" do
        trust = create(:trust)
        vacancy = create(:vacancy, :central_office)
        vacancy.organisation_vacancies.create(organisation: trust)

        expect(vacancy.parent_organisation_name).to eq(trust.name)
      end
    end
  end

  describe "#can_receive_job_applications?" do
    context "when the vacancy can receive job applications" do
      subject { create(:vacancy, :published, enable_job_applications: true) }

      it "returns true" do
        expect(subject.can_receive_job_applications?).to be true
      end
    end

    context "when the vacancy does not enable_job_applications?" do
      subject { create(:vacancy, :published, enable_job_applications: false) }

      it "returns false" do
        expect(subject.can_receive_job_applications?).to be false
      end
    end

    context "when the vacancy is not published" do
      subject { create(:vacancy, :draft) }

      it "returns false" do
        expect(subject.can_receive_job_applications?).to be false
      end
    end

    context "when the vacancy is pending" do
      subject { create(:vacancy, :published, publish_on: Date.tomorrow) }

      it "returns false" do
        expect(subject.can_receive_job_applications?).to be false
      end
    end
  end

  describe "#application_link" do
    it "returns the url" do
      vacancy = create(:vacancy, application_link: "https://example.com")
      expect(vacancy.application_link).to eq("https://example.com")
    end

    context "when a protocol was not provided" do
      it "returns an absolute url with `http` as the protocol" do
        vacancy = create(:vacancy, application_link: "example.com")
        expect(vacancy.application_link).to eq("http://example.com")
      end
    end

    context "when only the `www` sub domain was provided" do
      it "returns an absolute url with `http` as the protocol" do
        vacancy = create(:vacancy, application_link: "www.example.com")
        expect(vacancy.application_link).to eq("http://www.example.com")
      end
    end
  end

  describe "#publish_equal_opportunities_report?" do
    subject { create(:vacancy) }

    before do
      stub_const("Vacancy::EQUAL_OPPORTUNITIES_PUBLICATION_THRESHOLD", statuses.count)
      statuses.each { |status| create(:job_application, status, vacancy: subject) }
    end

    context "when the vacancy has enough applications to publish the equal opportunities report" do
      context "when the application statuses are post-submission" do
        let(:statuses) { %i[status_reviewed status_shortlisted status_submitted status_unsuccessful status_withdrawn] }

        it "returns true" do
          expect(subject.publish_equal_opportunities_report?).to eq(true)
        end
      end

      context "when the vacancy has too few post-submission applications to publish the equal opportunities report" do
        let(:statuses) { %i[status_draft] }

        it "returns false" do
          expect(subject.publish_equal_opportunities_report?).to eq(false)
        end
      end
    end
  end

  context "stats updated at" do
    let(:expired_job) { create(:vacancy, :expired) }
    let(:stats_updated_at) { Vacancy.find(expired_job.id).stats_updated_at }

    it { expect(stats_updated_at).to be_nil }

    it "saves the time that the stats updated at" do
      travel_to(Time.zone.local("2019, 1, 1, 10, 4, 3")) do
        expired_job.update(listed_elsewhere: :listed_paid, hired_status: :hired_tvs)

        expect(stats_updated_at).to eq(Time.current)
      end
    end

    it "does not update the stats when you are updating the job summary" do
      travel_to(Time.zone.local("2019, 1, 1, 10, 4, 3")) do
        expired_job.update(job_advert: "I am description")

        expect(stats_updated_at).to be_nil
      end
    end
  end

  describe "validations" do
    describe "changing enable_job_applications" do
      subject { build_stubbed(:vacancy, status, enable_job_applications: true) }

      before do
        subject.enable_job_applications = false
      end

      context "when already listed" do
        let(:status) { :published }

        it "fails validation" do
          expect(subject).not_to be_valid
          expect(subject.errors).to include(:enable_job_applications)
        end
      end

      context "when draft" do
        let(:status) { :draft }

        it { is_expected.to be_valid }
      end

      context "when scheduled" do
        let(:status) { :draft }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "#set_mean_geolocation_from_postcode" do
    let(:school) { create(:school, geopoint: "POINT(1 2)", postcode: "A12 B34") }

    context "when at a single school" do
      subject { create(:vacancy, organisation_vacancies_attributes: [{ organisation: school }]) }

      before { subject.set_postcode_from_mean_geolocation }

      it "uses the school's postcode" do
        expect(subject.postcode_from_mean_geolocation).to eq("A12 B34")
      end
    end

    context "when in a trust" do
      let(:trust) { create(:trust) }

      before { SchoolGroupMembership.create(school: school, school_group: trust) }

      context "when at a single school in a trust" do
        subject { create(:vacancy, :at_one_school, organisation_vacancies_attributes: [{ organisation: school }]) }

        before { subject.set_postcode_from_mean_geolocation }

        it "uses the school's postcode" do
          expect(subject.postcode_from_mean_geolocation).to eq("A12 B34")
        end
      end

      context "when at multiple schools in a school group" do
        subject { create(:vacancy, :at_multiple_schools) }
        let(:school2) { create(:school, geopoint: "POINT(5 6)") }
        let(:geocoding) { instance_double(Geocoding) }

        before do
          SchoolGroupMembership.create(school: school2, school_group: trust)
          OrganisationVacancy.create(organisation: school, vacancy: subject)
          allow(Geocoding).to receive(:new).with([3.0, 4.0]).and_return(geocoding)
          allow(geocoding).to receive(:postcode_from_coordinates).and_return("New postcode")
          OrganisationVacancy.create(organisation: school2, vacancy: subject)
          subject.set_postcode_from_mean_geolocation
        end

        it "sets postcode_from_mean_geolocation to the output of Geocoding#postcode_from_coordinates, using the mean of the two geolocations" do
          expect(subject.postcode_from_mean_geolocation).to eq("New postcode")
        end
      end
    end
  end
end
