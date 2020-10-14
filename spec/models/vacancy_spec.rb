require 'rails_helper'
RSpec.describe Vacancy, type: :model do
  it { should belong_to(:publisher_user).optional }
  it { should have_many(:documents) }
  it { should have_many(:organisation_vacancies) }
  it { should have_many(:organisations) }

  context 'indexing for search' do
    describe '#update_index!' do
      it { should have_db_column(:initially_indexed) }
      it { should have_db_index(:initially_indexed) }

      it 'indexes `live` records where `initially_indexed == false`' do
        allow(described_class).to receive_message_chain(:unindexed, :update_all).with({ initially_indexed: true })
        expect(described_class).to receive_message_chain(:unindexed, :algolia_reindex!)
        described_class.update_index!
      end

      it 'flags indexed records as `initially_indexed = true`' do
        allow(described_class).to receive_message_chain(:unindexed, :algolia_reindex!)
        expect(described_class).to receive_message_chain(:unindexed, :update_all).with({ initially_indexed: true })
        described_class.update_index!
      end
    end

    describe '#reindex!' do
      it 'is overridden so that it only indexes vacancies scoped as `live`' do
        expect(described_class).to receive_message_chain(:live, :includes, :algolia_reindex!)
        described_class.reindex!
      end
    end

    describe '#reindex' do
      it 'is overridden so that it only indexes vacancies scoped as `live`' do
        expect(described_class).to receive_message_chain(:live, :includes, :algolia_reindex)
        described_class.reindex
      end
    end

    describe '#remove_vacancies_that_expired_yesterday!' do
      it 'selects all records that expired yesterday' do
        expect(described_class).to receive(:where)
          .with('expiry_time BETWEEN ? AND ?', Time.zone.yesterday.midnight, Time.zone.today.midnight)
        described_class.remove_vacancies_that_expired_yesterday!
      end

      it 'calls .index.delete_objects on the expired records' do
        vacancy = double(Vacancy, id: 'ABC123')
        allow(described_class).to receive(:where).and_return([vacancy])
        expect(described_class).to receive_message_chain(:index, :delete_objects).with(%w[ABC123])
        described_class.remove_vacancies_that_expired_yesterday!
      end
    end
  end

  describe 'validations' do
    context 'a new record' do
      it 'should validate presence of about_school' do
        subject.about_school = ''
        expect(subject.valid?).to be(false)
      end
      it { should validate_presence_of(:contact_email) }
      it { should validate_presence_of(:expires_on) }
      it { should validate_presence_of(:job_summary) }
      it { should validate_presence_of(:job_title) }
      it { should validate_presence_of(:publish_on) }
      it { should validate_presence_of(:salary) }
      it { should validate_presence_of(:working_patterns) }
    end

    context 'a record saved with job spec details' do
      subject { create(:vacancy) }

      context 'does not validate candidate specification fields' do
        it { should_not validate_presence_of(:education) }
        it { should_not validate_presence_of(:qualifications) }
        it { should_not validate_presence_of(:experience) }
      end
    end

    context 'set minimum length of mandatory fields' do
      subject { build(:vacancy, :fail_minimum_validation) }
      before(:each) do
        subject.valid?
      end

      it '#job_title' do
        expect(subject.errors.messages[:job_title].first)
          .to eq(I18n.t('activerecord.errors.models.vacancy.attributes.job_title.too_short', count: 4))
      end
    end

    context 'restrict maximum length of string fields' do
      subject { build(:vacancy, :fail_maximum_validation) }
      before(:each) do
        subject.valid?
      end

      it '#job_title' do
        expect(subject.errors.messages[:job_title].first)
          .to eq(I18n.t('activemodel.errors.models.job_specification_form.attributes.job_title.too_long', count: 100))
      end

      it '#salary' do
        expect(subject.errors.messages[:salary].first)
          .to eq(I18n.t('activemodel.errors.models.pay_package_form.attributes.salary.too_long', count: 256))
      end
    end

    context 'a record saved with job spec details, ' \
      'and empty contact_email' do
      subject { build(:vacancy, status: :draft) }
      before { subject.contact_email = '' }

      it 'should validate presence of contact email' do
        expect(subject.valid?).to be_falsy
        expect(subject.errors.messages[:contact_email]).not_to eql([])
      end

      it { should validate_presence_of(:publish_on) }
      it { should validate_presence_of(:expires_on) }
    end
  end

  describe 'friendly_id generated slug' do
    describe '#slug' do
      it 'the slug cannot be duplicate' do
        green_school = create(:school, name: 'Green school', town: 'Greenway', county: 'Mars')
        blue_school = create(:school, name: 'Blue school')

        first_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher',
                                                           organisation_vacancies_attributes: [{ organisation: blue_school }])
        second_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher',
                                                            organisation_vacancies_attributes: [{ organisation: green_school }])
        third_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher',
                                                           organisation_vacancies_attributes: [{ organisation: green_school }])
        fourth_maths_teacher = create(:vacancy, :published, job_title: 'Maths Teacher',
                                                            organisation_vacancies_attributes: [{ organisation: green_school }])

        expect(first_maths_teacher.slug).to eq('maths-teacher')
        expect(second_maths_teacher.slug).to eq('maths-teacher-green-school')
        expect(third_maths_teacher.slug).to eq('maths-teacher-green-school-greenway-mars')

        expect(fourth_maths_teacher.slug).to include('maths-teacher')
        expect(fourth_maths_teacher.slug).not_to eq('maths-teacher')
        expect(fourth_maths_teacher.slug).not_to eq('maths-teacher-green-school')
        expect(fourth_maths_teacher.slug).not_to eq('maths-teacher-green-school-greenway-mars')
      end
    end

    describe '#refresh_slug' do
      it 'resets the current slug by accessing a friendly_id private method' do
        job = create(:vacancy, slug: 'the-wrong-slug')
        job.job_title = 'CS Teacher'
        job.refresh_slug

        expect(job.slug).to eq('cs-teacher')
      end
    end

    describe '#listed?' do
      let(:datetime) do
        instance_double(DateTime)
      end

      subject do
        build(:vacancy, :published)
      end

      it 'does not break if #expiry_time is nil' do
        subject.expiry_time = nil
        expect { subject.listed? }.not_to raise_error
      end

      it 'checks #expiry_time is in the future' do
        allow(subject).to receive(:expiry_time).and_return(datetime)
        expect(datetime).to receive(:future?)
        subject.listed?
      end

      it 'checks #published?' do
        expect(subject).to receive(:published?)
        subject.listed?
      end

      it 'checks if #published == "draft" (yields published? == false)' do
        subject.status = 'draft'
        expect(subject.listed?).to be_falsey
      end

      describe '#publish_on' do
        before do
          allow(subject).to receive(:publish_on).and_return(datetime)
          allow(datetime).to receive(:past?)
          allow(datetime).to receive(:today?)
        end

        it 'checks if #publish_on is in the past' do
          expect(datetime).to receive(:past?)
          subject.listed?
        end

        it 'checks if #publish_on is today' do
          expect(datetime).to receive(:today?)
          subject.listed?
        end

        it 'does not break if publish_on is nil' do
          subject.publish_on = nil
          expect { subject.listed? }.not_to raise_error
        end
      end

      it 'return true if all the conditions are met' do
        expect(subject.listed?).to be_truthy
      end
    end
  end

  context 'actions' do
    describe '#trash!' do
      it 'sets a vacancy to trashed and does not retrieve it in the applicable scope' do
        vacancies = create_list(:vacancy, 4)
        vacancies.last.trashed!
        expect(Vacancy.active.count).to eq(3)
        vacancies.first.trashed!
        expect(Vacancy.active.count).to eq(2)
      end
    end
  end

  context 'scopes' do
    let(:expired_earlier_today) do
      build(:vacancy, expires_on: Time.zone.today,
                      expiry_time: Time.zone.now - 1.hour)
    end
    let(:expires_later_today) do
      create(:vacancy, status: :published,
                       expiry_time: Time.zone.now + 1.hour)
    end
    describe '#applicable' do
      context 'when expiry time not given' do
        it 'finds current vacancies' do
          expired = build(:vacancy, :expired)
          expired.send :set_slug
          expired.save(validate: false)
          expires_today = create(:vacancy, :with_no_expiry_time, expires_on: Time.zone.today)
          expires_future = create(:vacancy, :with_no_expiry_time, expires_on: 3.months.from_now)

          results = Vacancy.applicable
          expect(results).to include(expires_today)
          expect(results).to include(expires_future)
          expect(results).to_not include(expired)
        end
      end

      context 'when expiry time given' do
        it 'finds current vacancies' do
          expired_earlier_today.send :set_slug
          expired_earlier_today.save(validate: false)

          results = Vacancy.applicable
          expect(results).to include(expires_later_today)
          expect(results).to_not include(expired_earlier_today)
        end
      end
    end

    describe '#active' do
      it 'retrieves active vacancies that have a status of :draft or :published' do
        draft = create_list(:vacancy, 2, :draft)
        published = create_list(:vacancy, 5, :published)
        create_list(:vacancy, 4, :trashed)

        expect(Vacancy.active.count).to eq(draft.count + published.count)
      end
    end

    describe '#listed' do
      it 'retrieves vacancies that have a status of :published and a past publish_on date' do
        published = create_list(:vacancy, 5, :published)
        create_list(:vacancy, 3, :future_publish)
        create_list(:vacancy, 4, :trashed)

        expect(Vacancy.listed.count).to eq(published.count)
      end
    end

    describe '#pending' do
      it 'retrieves vacancies that have a status of :published, a future publish_on date & a future expires_on date' do
        create_list(:vacancy, 5, :published)
        pending = create_list(:vacancy, 3, :future_publish)

        expect(Vacancy.pending.count).to eq(pending.count)
      end
    end

    describe '#draft' do
      it 'retrieves vacancies that have a status of :draft' do
        create_list(:vacancy, 5, :published)
        draft = create_list(:vacancy, 3, :draft)

        expect(Vacancy.draft.count).to eq(draft.count)
      end
    end

    describe '#expired' do
      context 'when expiry time not given' do
        it 'retrieves vacancies that have a past expires_on date' do
          create_list(:vacancy, 5, :published)
          expired = build(:vacancy, :expired)
          expired.send :set_slug
          expired.save(validate: false)

          expect(Vacancy.expired.count).to eq(1)
        end
      end

      context 'when expiry time given' do
        it 'retrieves vacancies that have a past expires_on date' do
          create_list(:vacancy, 5, :published)
          expired = build(:vacancy, expiry_time: Time.zone.now - 1.hour)
          expired.send :set_slug
          expired.save(validate: false)

          expect(Vacancy.expired.count).to eq(1)
        end
      end
    end

    describe '#live' do
      context 'when expiry time not given' do
        let!(:live) { create_list(:vacancy, 5, :published) }

        it 'retrieves vacancies that have a status of :published, a past publish_on date & a future expires_on date' do
          expired = build(:vacancy, :expired)
          expired.send :set_slug
          expired.save(validate: false)

          create_list(:vacancy, 3, :future_publish)

          trashed = build(:vacancy, :trashed)
          trashed.send :set_slug
          trashed.save(validate: false)

          expect(Vacancy.live.count).to eq(live.count)
          expect(Vacancy.live).to_not include(expired)
          expect(Vacancy.live).to_not include(trashed)
        end

        it 'includes vacancies that expire today' do
          expires_today = create(:vacancy, :with_no_expiry_time, expires_on: Time.zone.today)

          expect(Vacancy.live).to include(expires_today)
        end
      end

      context 'when expiry time given' do
        it 'includes vacancies till expiry time' do
          expect(Vacancy.live).to include(expires_later_today)
          expect(Vacancy.live).to_not include(expired_earlier_today)
        end
      end
    end

    describe '#published_on_count(date)' do
      it 'retrieves vacancies listed on the specified date' do
        published_today = create_list(:vacancy, 3, :published_slugged)
        published_yesterday = build_list(:vacancy, 2, :published_slugged, publish_on: 1.day.ago)
        published_yesterday.each { |v| v.save(validate: false) }
        published_the_other_day = build_list(:vacancy, 1, :published_slugged, publish_on: 2.days.ago)
        published_the_other_day.each { |v| v.save(validate: false) }
        published_some_other_day = build_list(:vacancy, 6, :published_slugged, publish_on: 1.month.ago)
        published_some_other_day.each { |v| v.save(validate: false) }

        expect(Vacancy.published_on_count(Time.zone.today)).to eq(published_today.count)
        expect(Vacancy.published_on_count(1.day.ago)).to eq(published_yesterday.count)
        expect(Vacancy.published_on_count(2.days.ago)).to eq(published_the_other_day.count)
        expect(Vacancy.published_on_count(1.month.ago)).to eq(published_some_other_day.count)
      end
    end

    describe '#awaiting_feedback' do
      it 'gets all vacancies awaiting feedback' do
        expired_and_awaiting = create_list(:vacancy, 2, :expired)
        create_list(:vacancy, 3, :expired, listed_elsewhere: :listed_paid, hired_status: :hired_tvs)
        create_list(:vacancy, 3, :published_slugged)

        expect(Vacancy.awaiting_feedback.count).to eq(expired_and_awaiting.count)
      end
    end
  end

  describe 'when supporting documents are provided' do
    it 'should return the document name' do
      document = create(:document, name: 'Test_doc.png')
      vacancy = create(:vacancy, documents: [document])
      expect(vacancy.documents.first.name).to eq('Test_doc.png')
    end
  end

  describe '#parent_organisation_name' do
    context 'when vacancy has a school' do
      it 'returns the school name for the vacancy' do
        school = create(:school, name: 'St James School')
        vacancy = create(:vacancy)
        vacancy.organisation_vacancies.create(organisation: school)

        expect(vacancy.parent_organisation_name).to eq(school.name)
      end
    end

    context 'when vacancy has a school_group' do
      it 'returns the school_group name for the vacancy' do
        trust = create(:trust)
        vacancy = create(:vacancy, :at_central_office)
        vacancy.organisation_vacancies.create(organisation: trust)

        expect(vacancy.parent_organisation_name).to eq(trust.name)
      end
    end
  end

  describe '#application_link' do
    it 'returns the url' do
      vacancy = create(:vacancy, application_link: 'https://example.com')
      expect(vacancy.application_link).to eql('https://example.com')
    end

    context 'when a protocol was not provided' do
      it 'returns an absolute url with `http` as the protocol' do
        vacancy = create(:vacancy, application_link: 'example.com')
        expect(vacancy.application_link).to eql('http://example.com')
      end
    end

    context 'when only the `www` sub domain was provided' do
      it 'returns an absolute url with `http` as the protocol' do
        vacancy = create(:vacancy, application_link: 'www.example.com')
        expect(vacancy.application_link).to eql('http://www.example.com')
      end
    end
  end

  describe '#delete_documents' do
    it 'deletes all attached supporting documents' do
      document1 = create(:document, name: 'document1.pdf')
      document2 = create(:document, name: 'document2.pdf')

      vacancy = create(:vacancy, documents: [document1, document2])

      document1_delete = instance_double(DocumentDelete)
      document2_delete = instance_double(DocumentDelete)

      allow(DocumentDelete).to receive(:new).with(document1).and_return(document1_delete)
      allow(DocumentDelete).to receive(:new).with(document2).and_return(document2_delete)

      expect(document1_delete).to receive(:delete)
      expect(document2_delete).to receive(:delete)

      vacancy.delete_documents
    end
  end

  context 'stats updated at' do
    let(:expired_job) { create(:vacancy, :expired) }
    let(:stats_updated_at) { Vacancy.find(expired_job.id).stats_updated_at }

    it { expect(stats_updated_at).to be_nil }

    it 'saves the time that the stats updated at' do
      travel_to(Time.zone.local('2019, 1, 1, 10, 4, 3')) do
        expired_job.update(listed_elsewhere: :listed_paid, hired_status: :hired_tvs)

        expect(stats_updated_at).to eq(Time.current)
      end
    end

    it 'does not update the stats when you are updating the job summary' do
      travel_to(Time.zone.local('2019, 1, 1, 10, 4, 3')) do
        expired_job.update(job_summary: 'I am description')

        expect(stats_updated_at).to be_nil
      end
    end
  end
end
