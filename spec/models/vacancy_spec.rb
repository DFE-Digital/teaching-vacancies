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

  describe "publish_on removal callback" do
    it "publish_on is not removed when creating a new draft" do
      draft_vacancy = create(:draft_vacancy, publish_on: Date.current)
      expect(draft_vacancy.publish_on).to be_present
    end

    it "publish_on is not removed when converting a draft to a published vacancy" do
      vacancy = create(:draft_vacancy, publish_on: Date.current)
      vacancy.update!(type: "PublishedVacancy")
      expect(vacancy.publish_on).to be_present
    end

    it "publish_on is removed when converting a published vacancy back into a draft" do
      vacancy = create(:vacancy, publish_on: Date.current)
      expect { vacancy.update(type: "DraftVacancy") }.to change { vacancy.publish_on }.from(Date.current).to(nil)
    end
  end

  describe "validations" do
    describe "changing enable_job_applications" do
      subject { vacancy }

      before do
        subject.enable_job_applications = false
      end

      context "when already listed" do
        let(:vacancy) { build_stubbed(:vacancy, enable_job_applications: true) }

        it "fails validation" do
          expect(subject).not_to be_valid
          expect(subject.errors).to include(:enable_job_applications)
        end
      end

      context "when draft" do
        let(:vacancy) { build_stubbed(:draft_vacancy, enable_job_applications: true) }

        it { is_expected.to be_valid }
      end

      context "when scheduled" do
        let(:vacancy) { build_stubbed(:draft_vacancy, enable_job_applications: true) }

        it { is_expected.to be_valid }
      end
    end

    describe "organisation association" do
      it "is valid when an associated organisation has validation errors" do
        publisher = build_stubbed(:publisher)
        invalid_school = School.new(email: "invalid")
        expect(invalid_school).not_to be_valid

        expect(DraftVacancy.new(organisations: [invalid_school], publisher: publisher)).to be_valid
      end
    end

    describe "publish_on validation" do
      it "enforces publish_on presence for published vacancies" do
        vacancy = build_stubbed(:vacancy, publish_on: nil)
        expect(vacancy).not_to be_valid
        expect(vacancy.errors[:publish_on]).to include("Enter publish date")
      end

      it "allows publish_on to be nil for draft vacancies" do
        vacancy = build_stubbed(:draft_vacancy, publish_on: nil)
        expect(vacancy).to be_valid
      end
    end
  end

  describe "#trash!" do
    subject { create(:vacancy) }

    it "discards the record" do
      subject.trash!
      expect(subject).to be_discarded
    end

    it "removes google index" do
      url = Rails.application.routes.url_helpers.job_url(subject)
      expect { subject.trash! }.to have_enqueued_job(RemoveGoogleIndexQueueJob).with(url)
    end

    it "removes attachements" do
      subject.trash!
      expect(subject.supporting_documents).to be_blank
    end

    context "when vacancy already trashed" do
      subject { create(:vacancy, :trashed) }

      it "does nothing" do
        expect { subject.trash! }.not_to have_enqueued_job(RemoveGoogleIndexQueueJob)
      end
    end
  end

  describe "#has_noticed_notifications" do
    subject { create(:vacancy) }

    let(:job_application) { create(:job_application, vacancy: subject) }

    before do
      Publishers::JobApplicationReceivedNotifier.with(vacancy: subject, job_application: job_application)
                                                .deliver(subject.publisher)
      expect(Noticed::Notification.count).to eq 1
      subject.destroy
    end

    it "removes the notification when destroyed" do
      expect(Noticed::Notification.count).to eq 0
    end
  end

  describe "indexing for search" do
    subject(:vacancy) { build(:vacancy) }

    let(:generator) { instance_double(Search::Postgres::TsvectorGenerator, tsvector: "'Hello'") }

    it "updates the searchable_content column on save" do
      allow(Search::Postgres::TsvectorGenerator).to receive(:new).with(Hash).and_return(generator)
      expect(subject.searchable_content).to be_nil
      subject.save
      expect(subject.searchable_content).to eq("'Hello'")
    end

    it "compacts the title before indexing" do
      vacancy.update(job_title: "Maths teacher maths maths maths!!!")
      expect(Search::Postgres::TsvectorGenerator).to receive(:new).with(hash_including(a: [%w[maths teacher], anything])).and_return(generator)
      vacancy.save
    end
  end

  describe "friendly_id generated slug" do
    describe "#slug" do
      it "the slug cannot be duplicate" do
        green_school = create(:school, name: "Green school", town: "Greenway", county: "Mars")
        blue_school = create(:school, name: "Blue school")

        first_maths_teacher = create(:vacancy, job_title: "Maths Teacher", organisations: [blue_school], expires_at: 1.day.from_now)
        second_maths_teacher = create(:vacancy, job_title: "Maths Teacher", organisations: [green_school], expires_at: 2.day.from_now)
        third_maths_teacher = create(:vacancy, job_title: "Maths Teacher", organisations: [green_school], expires_at: 3.day.from_now)
        fourth_maths_teacher = create(:vacancy, job_title: "Maths Teacher", organisations: [green_school], expires_at: 4.day.from_now)

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
      let(:datetime) { instance_double(DateTime) }
      let(:vacancy) { build(:vacancy) }

      subject do
        vacancy
      end

      it "does not break if #expires_at is nil" do
        subject.expires_at = nil
        expect { subject.live? }.not_to raise_error
      end

      it "checks #expires_at is in the future" do
        allow(subject).to receive(:expires_at).and_return(datetime)
        expect(datetime).to receive(:future?)
        subject.live?
      end

      it "checks #published?" do
        expect(subject).to receive(:published?)
        subject.live?
      end

      context "when draft" do
        let(:vacancy) { build(:draft_vacancy) }

        it 'checks if #published == "draft" (yields published? == false)' do
          expect(subject.live?).to be_falsey
        end
      end

      describe "#publish_on" do
        before do
          allow(subject).to receive(:publish_on).and_return(datetime)
          allow(datetime).to receive(:past?)
          allow(datetime).to receive(:today?)
        end

        it "checks if #publish_on is in the past" do
          expect(datetime).to receive(:past?)
          subject.live?
        end

        it "checks if #publish_on is today" do
          expect(datetime).to receive(:today?)
          subject.live?
        end

        it "does not break if publish_on is nil" do
          subject.publish_on = nil
          expect { subject.live? }.not_to raise_error
        end
      end

      it "return true if all the conditions are met" do
        expect(subject.live?).to be_truthy
      end
    end
  end

  context "scopes" do
    # rubocop:disable RSpec/IndexedLet
    describe ".active_in_current_academic_year" do
      let(:jun_1_2025) { Date.current.beginning_of_year.months_since(5) }
      let(:aug31_2025) { Date.current.end_of_year.months_ago(4) }
      let(:aug_31_2024) { aug31_2025 - 1.year }
      let(:sep_1_2025) { Date.current.beginning_of_year.months_since(8) }
      let(:sep_2_2025) { sep_1_2025 + 1.day }
      let(:sep_1_2024) { sep_1_2025 - 1.year }
      let(:sep_2_2024) { sep_2_2025 - 1.year }

      before do
        create(:vacancy, publish_on: 2.years.ago, expiry_date: 2.years.ago, job_title: "expired_years_ago")
        create(:vacancy, publish_on: sep_2_2024, expiry_date: aug31_2025, job_title: "academic_24_25")
        create(:vacancy, publish_on: jun_1_2025, expiry_date: sep_2_2025, job_title: "academic_24_26")
        create(:vacancy, publish_on: aug_31_2024, expiry_date: aug_31_2024, job_title: "aug_31_2024")
        create(:vacancy, publish_on: sep_1_2024, expiry_date: sep_2_2024, job_title: "sep_2_2024")
        create(:vacancy, publish_on: aug31_2025, expiry_date: aug31_2025, job_title: "aug_31_2025")
        create(:vacancy, publish_on: sep_1_2025, expiry_date: sep_2_2025, job_title: "sep_2_2025")

        travel_to(today)
      end

      context "when in July 2025" do
        let(:today) { Date.current.beginning_of_year.months_since(6) }

        it "finds vacancies from 2024-25" do
          expect(described_class.active_in_current_academic_year.map(&:job_title))
            .to contain_exactly("academic_24_25", "academic_24_26", "sep_2_2024")
        end
      end

      context "when in Oct 2025" do
        let(:today) { Date.current.beginning_of_year.months_since(9) }

        it "finds vacancies from 2025-26" do
          expect(described_class.active_in_current_academic_year.map(&:job_title))
            .to contain_exactly("academic_24_26", "sep_2_2025")
        end
      end

      context "when in June 2026" do
        let(:today) { Date.current.end_of_year.months_since(6) }

        it "finds vacancies from 2025-26" do
          expect(described_class.active_in_current_academic_year.map(&:job_title))
            .to contain_exactly("academic_24_26", "sep_2_2025")
        end
      end
    end
    # rubocop:enable RSpec/IndexedLet

    describe "#expired" do
      it "retrieves published vacancies that have a past expires_at" do
        create_list(:vacancy, 5)
        expired = build(:vacancy, expires_at: Time.current - 1.hour)
        expired.send :set_slug
        expired.save(validate: false)

        expect(PublishedVacancy.expired.count).to eq(1)
      end
    end

    describe "#expired_yesterday" do
      before do
        create(:vacancy, :expires_tomorrow)
      end

      let!(:yesterday) { create(:vacancy, :expired_yesterday) }
      it "retrieves published and unpublished vacancies that have an expires_at of yesterday" do
        expect(PublishedVacancy.expired_yesterday).to eq([yesterday])
      end
    end

    context "with expiring vacancies" do
      let!(:expired_earlier_today) { create(:vacancy, expires_at: 5.hour.ago) }
      let!(:expires_later_today) { create(:vacancy, expires_at: 1.hour.from_now) }

      describe "#applicable" do
        it "finds current vacancies" do
          expired_earlier_today.send :set_slug
          expired_earlier_today.save(validate: false)

          results = PublishedVacancy.applicable
          expect(results).to include(expires_later_today)
          expect(results).to_not include(expired_earlier_today)
        end
      end

      describe "#expires_within_data_access_period" do
        let!(:expired_years_ago) { create(:vacancy, expires_at: 2.years.ago) }

        it "retrieves vacancies that expired not more than one year ago" do
          expect(PublishedVacancy.expires_within_data_access_period).to_not include(expired_years_ago)
          expect(PublishedVacancy.expires_within_data_access_period).to include(expired_earlier_today)
        end
      end

      describe "#live" do
        it "includes vacancies till expiry time" do
          expect(PublishedVacancy.live).to include(expires_later_today)
          expect(PublishedVacancy.live).to_not include(expired_earlier_today)
        end
      end
    end

    describe "#listed" do
      it "retrieves vacancies that have a status of :published and a past publish_on date" do
        published = create_list(:vacancy, 5)
        create_list(:vacancy, 3, :future_publish)

        expect(PublishedVacancy.listed.count).to eq(published.count)
      end
    end

    describe "#pending" do
      before do
        create_list(:vacancy, 5)
        create_list(:vacancy, 3, :future_publish)
      end

      it "retrieves vacancies that have a status of :published, a future publish_on date & a future expires_at date" do
        expect(PublishedVacancy.pending.count).to eq(3)
      end
    end

    describe "#awaiting_feedback_recently_expired" do
      it "includes only vacancies that expired within the last 2 months and are awaiting feedback" do
        recent_expired_and_awaiting_feedback = create(:vacancy, :expired, expires_at: 1.month.ago)
        old_expired_and_awaiting_feedback = create(:vacancy, :expired, expires_at: 3.months.ago)
        recent_expired_and_not_awaiting_feedback = create(:vacancy, :expired, expires_at: 1.month.ago, listed_elsewhere: :listed_paid)

        results = PublishedVacancy.awaiting_feedback_recently_expired

        expect(results).to include(recent_expired_and_awaiting_feedback)
        expect(results).not_to include(old_expired_and_awaiting_feedback)
        expect(results).not_to include(recent_expired_and_not_awaiting_feedback)
      end
    end
  end

  describe "#organisation_name" do
    context "when vacancy has a school" do
      let(:school) { create(:school, name: "St James School") }
      let(:vacancy) { create(:vacancy, organisations: [school]) }

      it "returns the school name for the vacancy" do
        expect(vacancy.organisation_name).to eq(school.name)
      end
    end

    context "when vacancy has a school_group" do
      let(:trust) { create(:trust) }
      let(:vacancy) { create(:vacancy, organisations: [trust]) }

      it "returns the school_group name for the vacancy" do
        expect(vacancy.organisation_name).to eq(trust.name)
      end
    end
  end

  describe "#can_receive_job_applications?" do
    context "when the vacancy can receive job applications" do
      subject { create(:vacancy, enable_job_applications: true) }

      it "returns true" do
        expect(subject.can_receive_job_applications?).to be true
      end
    end

    context "when the vacancy does not enable_job_applications?" do
      subject { create(:vacancy, enable_job_applications: false) }

      it "returns false" do
        expect(subject.can_receive_job_applications?).to be false
      end
    end

    context "when the vacancy is not published" do
      subject { create(:draft_vacancy) }

      it "returns false" do
        expect(subject.can_receive_job_applications?).to be false
      end
    end

    context "when the vacancy is pending" do
      subject { create(:vacancy, publish_on: Date.tomorrow) }

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
    let(:stats_updated_at) { PublishedVacancy.find(expired_job.id).stats_updated_at }

    it { expect(stats_updated_at).to be_nil }

    it "saves the time that the stats updated at" do
      travel_to(Time.zone.local(2019, 1, 1, 10, 4, 3)) do
        expired_job.update(listed_elsewhere: :listed_paid, hired_status: :hired_tvs)

        expect(stats_updated_at).to eq(Time.current)
      end
    end
  end

  describe "#allow_phase_to_be_set?" do
    context "when the vacancy is at the a school with a phase" do
      subject { create(:vacancy, organisations: [create(:school, phase: :secondary)]) }

      it "returns false" do
        expect(subject.allow_phase_to_be_set?).to be false
      end
    end

    context "when the vacancy is at the a school with no phase" do
      subject { create(:vacancy, organisations: [create(:school, phase: :not_applicable)]) }

      it "returns true" do
        expect(subject.allow_phase_to_be_set?).to be true
      end
    end
  end

  describe "#allow_key_stages?" do
    context "when one of the phases of the vacancy is among [primary middle secondary through]" do
      subject { create(:vacancy, :secondary) }

      it "returns false" do
        expect(subject.allow_key_stages?).to be(true)
      end
    end

    context "when none of the phases of the vacancy is among [primary middle secondary through]" do
      subject { create(:vacancy, phases: %w[nursery]) }

      it "returns true" do
        expect(subject.allow_key_stages?).to be(false)
      end
    end
  end

  describe "#reset_dependent_fields" do
    context "when changing working pattern to full time" do
      subject { create(:vacancy, working_patterns: ["part_time"], actual_salary: "50000") }

      before { subject.update working_patterns: ["full_time"] }

      it "resets actual_salary field" do
        expect(subject.actual_salary).to be_blank
      end
    end

    context "when changing contract type to permanent" do
      subject { create(:vacancy, contract_type: "fixed_term", fixed_term_contract_duration: "8 months") }

      before { subject.update contract_type: "permanent" }

      it "resets fixed_term_contract_duration field" do
        expect(subject.fixed_term_contract_duration).to be_blank
      end
    end

    context "when phase is changed from primary to secondary" do
      subject { create(:vacancy, phases: ["primary"], subjects: %w[English]) }

      before do
        subject.assign_attributes(phases: ["secondary"])
        subject.save
      end

      it "drops the subjects" do
        expect(subject.subjects).to be_empty
      end
    end

    context "when role is changed from teacher to sendo" do
      subject { create(:vacancy, job_roles: ["teacher"], key_stages: %w[ks2]) }

      before do
        subject.assign_attributes(job_roles: ["sendco"])
        subject.save
      end

      it "drops the subjects" do
        expect(subject.subjects).to be_empty
      end
    end
  end

  describe "#geolocation" do
    subject { create(:vacancy, organisations: organisations) }

    context "for single school vacancies" do
      let(:organisations) { [create(:school, geopoint: "POINT(1 2)")] }

      it "is set to a point" do
        expect(subject.geolocation.lat).to eq(2)
        expect(subject.geolocation.lon).to eq(1)
      end
    end

    context "for trust central office vacancies" do
      let(:organisations) { [create(:trust, geopoint: "POINT(1 2)")] }

      it "is set to a point" do
        expect(subject.geolocation.lat).to eq(2)
        expect(subject.geolocation.lon).to eq(1)
      end
    end

    context "for multi-school vacancies" do
      let(:organisations) { [create(:school, geopoint: "POINT(1 2)"), create(:school, geopoint: "POINT(3 4)")] }

      it "is set to a multipoint" do
        expect(subject.geolocation.map(&:lat)).to contain_exactly(2, 4)
        expect(subject.geolocation.map(&:lon)).to contain_exactly(1, 3)
      end
    end

    context "if all organisations have no geopoint" do
      let(:organisations) { [create(:school, geopoint: nil), create(:school, geopoint: nil)] }

      it "is set to nil" do
        expect(subject.geolocation).to be_nil
      end
    end
  end

  describe "#external?" do
    let!(:ats_api_client_vacancy) { create(:vacancy, :external, job_title: "v1", external_source: nil) }
    let!(:external_source_vacancy) { create(:vacancy, :external, job_title: "v2", publisher_ats_api_client: nil) }
    let!(:internal_vacancy) { create(:vacancy, job_title: "v3", external_source: nil, publisher_ats_api_client: nil) }

    it "is external when external_source is present" do
      expect(ats_api_client_vacancy.external?).to be true
    end

    it "is external when ats api client id is present" do
      expect(external_source_vacancy.external?).to be true
    end

    it "is not external when none of the external attributes are present" do
      expect(internal_vacancy.external?).to be false
    end

    it "matches external scopes" do
      expect(PublishedVacancy.external).to contain_exactly(ats_api_client_vacancy, external_source_vacancy)
    end

    it "matches internal scopes" do
      expect(PublishedVacancy.internal.map(&:job_title)).to contain_exactly(internal_vacancy.job_title)
    end
  end

  describe "#trust_uid" do
    let(:vacancy) { create(:vacancy, organisations: organisations) }

    subject(:trust_uid) { vacancy.trust_uid }

    context "when the organisation is a school not belonging to a school group" do
      let(:school) { create(:school) }
      let(:organisations) { [school] }

      it { is_expected.to be_nil }
    end

    context "when the organisation is a school belonging to a trust" do
      let(:trust) { create(:trust, uid: "12345") }
      let(:school) { create(:school, school_groups: [trust]) }
      let(:organisations) { [school] }

      it "returns the trust UID" do
        expect(trust_uid).to eq("12345")
      end
    end

    context "when the organisation is a school belonging to a school group with no UID" do
      let(:school_group) { create(:trust, uid: nil) }
      let(:school) { create(:school, school_groups: [school_group]) }
      let(:organisations) { [school] }

      it { is_expected.to be_nil }
    end

    context "when the organisation is a school belonging to multiple school groups and a trust" do
      let(:school_group_a) { create(:school_group, uid: nil) }
      let(:school_group_b) { create(:school_group, uid: nil) }
      let(:trust) { create(:trust, uid: "12345") }
      let(:school) { create(:school, school_groups: [school_group_a, school_group_b, trust]) }
      let(:organisations) { [school] }

      it "returns the trust UID" do
        expect(trust_uid).to eq("12345")
      end
    end

    context "when the organisation is a trust" do
      let(:school_group) { create(:trust, uid: "12345") }
      let(:organisations) { [school_group] }

      it "returns the trust UID" do
        expect(trust_uid).to eq("12345")
      end
    end

    context "when the organisation is a school group with no UID" do
      let(:school_group) { create(:school_group, uid: nil) }
      let(:organisations) { [school_group] }

      it { is_expected.to be_nil }
    end
  end

  describe "#distance_in_miles_to" do
    let(:test_coordinates) { Geocoding.new("Stonehenge").coordinates }
    subject { create(:vacancy, organisations: organisations) }

    context "when vacancy has multiple geolocations" do
      let(:glasgow_school) { create(:school, geopoint: "POINT(-4.2542 55.8628)") } # 338 miles from stonehenge
      let(:manchester_school) { create(:school, geopoint: "POINT(-2.2374 53.4810)") } # 159 miles from stonehenge
      let(:canary_wharf_school) { create(:school, geopoint: "POINT(-0.019501 51.504949)") } # 81 miles from stonehenge
      let(:organisations) { [glasgow_school, manchester_school, canary_wharf_school] }

      it "returns distance to the nearest school for a given location" do
        expect(subject.distance_in_miles_to(test_coordinates).floor).to eq 81
      end
    end

    context "when vacancy has one geolocation" do
      let(:organisations) { [create(:school, geopoint: "POINT(-2.983333 53.400002)")] } # 161 miles from stonehenge

      it "returns the distance to given location" do
        expect(subject.distance_in_miles_to(test_coordinates).floor).to eq 161
      end
    end
  end

  describe "draft!" do
    subject { create(:vacancy, :future_publish) }

    before { subject.update!(type: "DraftVacancy") }

    it "resets the publish_on date" do
      expect(subject.publish_on).to eq(nil)
    end
  end

  describe "#teaching_or_middle_leader_role?" do
    let(:vacancy) { create(:vacancy, job_roles: job_roles) }

    context "when job_roles includes a teaching role" do
      let(:job_roles) { ["teacher"] }

      it "returns true" do
        expect(vacancy.teaching_or_middle_leader_role?).to be true
      end
    end

    context "when job_roles includes a middle leader role" do
      let(:job_roles) { ["head_of_year_or_phase"] }

      it "returns true" do
        expect(vacancy.teaching_or_middle_leader_role?).to be true
      end
    end

    context "when job_roles includes multiple valid roles" do
      let(:job_roles) { ["teacher", "head_of_department_or_curriculum"] }

      it "returns true" do
        expect(vacancy.teaching_or_middle_leader_role?).to be true
      end
    end

    context "when job_roles does not include any teaching or middle leader role" do
      let(:job_roles) { ["administration_hr_data_and_finance"] }

      it "returns false" do
        expect(vacancy.teaching_or_middle_leader_role?).to be false
      end
    end

    context "when job_roles is empty" do
      let(:job_roles) { [] }

      it "returns false" do
        expect(vacancy.teaching_or_middle_leader_role?).to be false
      end
    end
  end

  describe "#find_conflicting_vacancy" do
    let(:school) { create(:school) }
    let(:publisher_ats_api_client) { create(:publisher_ats_api_client) }
    let(:vacancy) do
      build(:vacancy, :external, external_reference: "REF123", publisher_ats_api_client:, organisations: [school])
    end

    it "returns nil when no conflicting vacancy exists" do
      expect(vacancy.find_conflicting_vacancy).to be_nil
    end

    context "when there is a vacancy with the same ATS client ID and external reference" do
      let!(:conflicting_vacancy) do
        create(:vacancy, :external, external_reference: "REF123", publisher_ats_api_client:, organisations: [school])
      end

      it "returns the conflicting vacancy" do
        expect(vacancy.find_conflicting_vacancy).to eq(conflicting_vacancy)
      end
    end

    context "when there is a vacancy with the same ATS client ID but different external reference" do
      before do
        create(:vacancy, :external, external_reference: "REF456", publisher_ats_api_client:, organisations: [school])
      end

      it "returns nil" do
        expect(vacancy.find_conflicting_vacancy).to be_nil
      end
    end

    context "when there is a vacancy with the same external reference but different ATS client ID" do
      before do
        create(:vacancy, :external, external_reference: "REF123", publisher_ats_api_client: nil, organisations: [school])
      end

      it "returns nil" do
        expect(vacancy.find_conflicting_vacancy).to be_nil
      end
    end

    context "when there is a vacancy with the same information" do
      let!(:conflicting_vacancy) do
        create(:vacancy,
               organisations: [school],
               job_title: vacancy.job_title,
               expires_at: vacancy.expires_at,
               working_patterns: vacancy.working_patterns,
               contract_type: vacancy.contract_type,
               phases: vacancy.phases,
               salary: vacancy.salary)
      end

      it "returns the conflicting vacancy" do
        expect(vacancy.find_conflicting_vacancy).to eq(conflicting_vacancy)
      end
    end

    context "when there are two conflicting vacancies one with the same reference and one with the same information" do
      let!(:conflicting_vacancy_with_same_reference) do
        create(:vacancy, :external, external_reference: "REF123", publisher_ats_api_client:, organisations: [school])
      end

      before do
        create(:vacancy,
               organisations: [school],
               job_title: vacancy.job_title,
               expires_at: vacancy.expires_at,
               working_patterns: vacancy.working_patterns,
               contract_type: vacancy.contract_type,
               phases: vacancy.phases,
               salary: vacancy.salary)
      end

      it "returns the conflicting vacancy with the same reference" do
        expect(vacancy.find_conflicting_vacancy).to eq(conflicting_vacancy_with_same_reference)
      end
    end
  end

  describe "#contact_email_belongs_to_a_publisher?" do
    subject { vacancy.contact_email_belongs_to_a_publisher? }

    context "when contact_email is blank" do
      let(:vacancy) { create(:vacancy, contact_email: nil) }

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "when contact_email is present" do
      let(:email) { "publisher@example.com" }
      let(:vacancy) { create(:vacancy, contact_email: email) }

      context "when a publisher exists with that email" do
        before { create(:publisher, email: email) }

        it "returns true" do
          expect(subject).to be true
        end
      end

      context "when no publisher exists with that email" do
        it "returns false" do
          expect(subject).to be false
        end
      end
    end
  end
end
