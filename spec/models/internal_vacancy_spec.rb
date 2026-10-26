require "rails_helper"

SALARY_OPTIONS = {
  salary: "full_time",
  actual_salary: "part_time",
  pay_scale: "pay_scale",
}.freeze

RSpec.describe InternalVacancy do
  it { is_expected.to validate_presence_of(:organisations) }

  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_length_of(:job_title).is_at_least(4).is_at_most(75) }

  it { is_expected.to validate_presence_of(:job_roles) }

  it { is_expected.to validate_presence_of(:phases) }

  describe "key stages validation" do
    let(:vacancy) { build_stubbed(:vacancy, :secondary, key_stages: key_stages) }

    context "when key stages selected and key stages not in allowed key stages" do
      before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

      let(:key_stages) { %w[ks1 ks5] }

      it "is invalid" do
        expect(vacancy).not_to be_valid
        expect(vacancy.errors.of_kind?(:key_stages, :inclusion)).to be true
      end
    end

    context "when no key stages selected" do
      before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

      let(:key_stages) { nil }

      it "is invalid" do
        expect(vacancy).not_to be_valid
        expect(vacancy.errors.of_kind?(:key_stages, :inclusion)).to be true
      end
    end

    context "when vacancy does not allow key stages" do
      before do
        allow(vacancy).to receive(:allow_key_stages?).and_return(false)
      end

      let(:key_stages) { %w[ks4 ks5] }

      it "is valid" do
        expect(vacancy).to be_valid
      end
    end

    context "when key stages selected and key stages in allowed key stages" do
      before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

      let(:key_stages) { %w[ks3 ks4] }

      it "is valid" do
        expect(vacancy).to be_valid
      end
    end
  end

  describe "confirm job address valuidation" do
    context "when all job address fields are blank" do
      subject { build(:vacancy) }

      it { is_expected.to be_valid }
    end

    context "when any address field is present" do
      subject { build(:vacancy, job_address_line1: "10 Main Street", job_address_town: "Brighton", job_address_postcode: "BN1 1AA", organisations: [college]) }

      let(:college) { build(:college) }

      it { is_expected.to be_valid }

      context "when job_address_line1 is missing" do
        subject { build(:vacancy, job_address_town: "Brighton", job_address_postcode: "BN1 1AA", organisations: [college]) }

        it { is_expected.to validate_presence_of(:job_address_line1) }
      end

      context "when job_address_town is missing" do
        subject { build(:vacancy, job_address_line1: "10 Main Street", job_address_postcode: "BN1 1AA", organisations: [college]) }

        it { is_expected.to validate_presence_of(:job_address_town) }
      end

      context "when job_address_postcode is missing" do
        subject { build(:vacancy, job_address_line1: "10 Main Street", job_address_town: "Brighton", organisations: [college]) }

        it { is_expected.to validate_presence_of(:job_address_postcode) }
      end
    end
  end

  describe "contract infiormation validation" do
    # subject(:form) { described_class.new(params) }
    subject(:form) { build(:vacancy, working_patterns:, working_patterns_details:, contract_type:) }

    let(:vacancy) { build(:vacancy) }
    let(:working_patterns) { nil }
    let(:working_patterns_details) { nil }
    let(:contract_type) { nil }
    # let(:params) { { working_patterns:, working_patterns_details:, contract_type: } }

    # before { form.valid? }

    it { is_expected.to validate_presence_of(:working_patterns) }

    it "validates 'is_job_share' presence" do
      pending("Internal Vacancy spike")

      expect(form).not_to be_valid
      expect(form.errors[:is_job_share]).to eq(["Select yes if this role can be done as a job share"])
    end

    describe "'is_job_share' validation" do
      it "errors when not answered" do
        pending("Internal Vacancy spike")

        expect(form).not_to be_valid
        expect(form.errors[:is_job_share]).to eq(["Select yes if this role can be done as a job share"])
      end

      it "accepts 'true' as an answer" do
        form.is_job_share = true
        form.validate
        expect(form.errors[:is_job_share]).to be_empty
      end

      it "accepts 'false' as an answer" do
        form.is_job_share = false
        form.validate
        expect(form.errors[:is_job_share]).to be_empty
      end
    end

    describe "#working_patterns_details" do
      context "when working_patterns_details does not exceed the maximum allowed length" do
        let(:working_patterns_details) { Faker::Lorem.sentence(word_count: 75) }

        it { is_expected.to allow_value(working_patterns_details).for(:working_patterns_details) }
      end

      context "when working_patterns_details exceeds the maximud allowed length" do
        let(:working_patterns_details) { Faker::Lorem.sentence(word_count: 76) }

        it "ensures working_patterns_details cannot exceed 75 words" do
          pending("Internal Vacancy spike")

          expect(form.errors.of_kind?(:working_patterns_details, :working_patterns_details_maximum_words)).to be true
        end
      end
    end

    describe "fixed_term_contract_duration validation" do
      context "when contract_type is fixed_term" do
        let(:contract_type) { "fixed_term" }

        it "is invalid without fixed_term_contract_duration" do
          form.fixed_term_contract_duration = nil
          form.validate
          expect(form.errors[:fixed_term_contract_duration]).to include("Enter the length of the fixed term contract")
        end

        it "is valid with a fixed_term_contract_duration" do
          form.fixed_term_contract_duration = "6 months"
          form.validate
          expect(form.errors[:fixed_term_contract_duration]).to be_empty
        end
      end
    end

    describe "is_parental_leave_cover validation" do
      context "when contract_type is fixed_term" do
        let(:contract_type) { "fixed_term" }

        it "is invalid without is_parental_leave_cover being true or false" do
          form.is_parental_leave_cover = nil
          form.validate
          expect(form.errors[:is_parental_leave_cover]).to include("Select yes if this role is covering maternity or paternity leave")
        end

        it "is valid when is_parental_leave_cover is true" do
          form.is_parental_leave_cover = true
          form.validate
          expect(form.errors[:is_parental_leave_cover]).to be_empty
        end

        it "is valid when is_parental_leave_cover is false" do
          form.is_parental_leave_cover = false
          form.validate
          expect(form.errors[:is_parental_leave_cover]).to be_empty
        end
      end
    end
  end

  describe "pay package validations" do
    # subject { described_class.new(params, vacancy) }
    subject { build(:vacancy, **params) }

    let(:vacancy) do
      build_stubbed(:vacancy,
                    salary: nil,
                    actual_salary: nil,
                    pay_scale: nil)
    end

    xdescribe "salary options" do
      SALARY_OPTIONS.each do |salary_value, salary_type|
        context "when only #{salary_type} salary is selected" do
          let(:params) { { salary_value => salary_type, benefits: "false" } }

          it { is_expected.to validate_presence_of(salary_value) }
          it { is_expected.to validate_length_of(salary_value).is_at_least(1).is_at_most(256) }

          (SALARY_OPTIONS.keys - [salary_value]).each do |other_salary_type|
            it { is_expected.not_to validate_presence_of(other_salary_type) }
          end
        end
      end
    end

    context "when there are no benefits" do
      let(:params) { { benefits: "false" } }

      it { is_expected.not_to validate_presence_of(:benefits_details) }
    end

    context "when there are benefits" do
      let(:params) { { benefits: "true" } }

      it { is_expected.to validate_presence_of(:benefits_details) }
      it { is_expected.to validate_length_of(:benefits_details).is_at_least(1).is_at_most(256) }
    end
  end

  describe "start date validations" do
    # subject { described_class.new(params) }
    subject(:new_vacancy) do
      build(:vacancy, start_date_type: start_date_type,
                      starts_on: starts_on,
                      earliest_start_date: earliest_start_date,
                      latest_start_date: latest_start_date,
                      other_start_date_details: other_start_date_details)
    end

    let(:vacancy) { build_stubbed(:vacancy) }

    let(:start_date_type) { "specific_date" }
    let(:starts_on) { 18.months.from_now }
    let(:earliest_start_date) { 18.months.from_now }
    let(:latest_start_date) { 19.months.from_now }
    let(:other_start_date_details) { nil }

    # let(:params) do
    #   {
    #     start_date_type: start_date_type,
    #     "starts_on(1i)" => starts_on.year.to_s,
    #     "starts_on(2i)" => starts_on.month.to_s,
    #     "starts_on(3i)" => starts_on.day.to_s,
    #     "earliest_start_date(1i)" => earliest_start_date.year.to_s,
    #     "earliest_start_date(2i)" => earliest_start_date.month.to_s,
    #     "earliest_start_date(3i)" => earliest_start_date.day.to_s,
    #     "latest_start_date(1i)" => latest_start_date.year.to_s,
    #     "latest_start_date(2i)" => latest_start_date.month.to_s,
    #     "latest_start_date(3i)" => latest_start_date.day.to_s,
    #     other_start_date_details: other_start_date_details,
    #     expires_at: vacancy.expires_at,
    #   }
    # end

    describe "start_date_type" do
      context "when blank" do
        let(:start_date_type) { nil }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:start_date_type, :inclusion)).to be true
        end
      end
    end

    describe "starts_on" do
      xcontext "when date is incomplete" do
        before { params["starts_on(2i)"] = "" }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:starts_on, :invalid)).to be true
        end
      end

      xcontext "when date is invalid" do
        before { params["starts_on(2i)"] = "100" }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:starts_on, :invalid)).to be true
        end
      end

      context "when date is not in the future" do
        let(:starts_on) { 1.year.ago }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:starts_on, :on_or_after)).to be true
        end
      end

      context "when date is too far in the future" do
        let(:starts_on) { 25.months.from_now }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:starts_on, :on_or_before)).to be true
        end
      end

      context "when date is before expires_at" do
        let(:starts_on) { 2.months.from_now }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:starts_on, :after)).to be true
        end
      end
    end

    describe "earliest_start_date" do
      let(:start_date_type) { "date_range" }

      xcontext "when date is incomplete" do
        before { params["earliest_start_date(2i)"] = "" }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:earliest_start_date, :invalid)).to be true
        end
      end

      xcontext "when date is invalid" do
        before { params["earliest_start_date(2i)"] = "100" }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:earliest_start_date, :invalid)).to be true
        end
      end

      context "when date is not in the future" do
        let(:earliest_start_date) { 1.year.ago }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:earliest_start_date, :on_or_after)).to be true
        end
      end

      context "when date is too far in the future" do
        let(:earliest_start_date) { 25.months.from_now }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:earliest_start_date, :on_or_before)).to be true
        end
      end

      context "when date is before expires_at" do
        let(:earliest_start_date) { 2.months.from_now }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:earliest_start_date, :after)).to be true
        end
      end
    end

    describe "latest_start_date" do
      let(:start_date_type) { "date_range" }

      xcontext "when date is incomplete" do
        before { params["latest_start_date(2i)"] = "" }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:latest_start_date, :invalid)).to be true
        end
      end

      xcontext "when date is invalid" do
        before { params["latest_start_date(2i)"] = "100" }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:latest_start_date, :invalid)).to be true
        end
      end

      context "when date is not in the future" do
        let(:latest_start_date) { 1.year.ago }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:latest_start_date, :on_or_after)).to be true
        end
      end

      context "when date is too far in the future" do
        let(:latest_start_date) { 25.months.from_now }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:latest_start_date, :on_or_before)).to be true
        end
      end

      context "when date is before expires_at" do
        let(:latest_start_date) { 9.months.from_now }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:latest_start_date, :after)).to be true
        end
      end

      context "when date is before earliest_start_date" do
        let(:latest_start_date) { earliest_start_date - 1.month }

        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:latest_start_date, :after)).to be true
        end
      end
    end

    describe ".load_from_params" do
      let(:start_date_type) { "date_range" }

      context "when earliest_start_date is on or before the closing date" do
        let(:earliest_start_date) { vacancy.expires_at.to_date }
        let(:latest_start_date) { earliest_start_date + 1.month }

        it "is invalid with a closing date error" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:earliest_start_date, :after)).to be true
        end
      end

      context "when starts_on is on or before the closing date" do
        let(:start_date_type) { "specific_date" }
        let(:starts_on) { vacancy.expires_at }

        it "is invalid with a closing date error" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:starts_on, :after)).to be true
        end
      end
    end

    describe "other_start_date_details" do
      let(:start_date_type) { "other" }

      context "when blank" do
        it "is invalid" do
          expect(new_vacancy).not_to be_valid
          expect(new_vacancy.errors.of_kind?(:other_start_date_details, :blank)).to be true
        end
      end

      context "when not blank" do
        let(:other_start_date_details) { "test" }

        it "is valid" do
          expect(new_vacancy).to be_valid
        end
      end
    end
  end
end
