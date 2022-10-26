require "rails_helper"

RSpec.describe Publishers::JobListing::AboutTheRoleForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher") }
  let(:organisation) { build_stubbed(:school) }
  let(:params) { {} }

  before { subject.valid? }

  it { is_expected.to validate_inclusion_of(:ect_status).in_array(Vacancy.ect_statuses.keys) }
  it { is_expected.to validate_inclusion_of(:safeguarding_information_provided).in_array([true, false, "true", "false"]) }
  it { is_expected.to validate_inclusion_of(:further_details_provided).in_array([true, false, "true", "false"]) }

  describe "skills_and_experience" do
    let(:error) { %i[skills_and_experience blank] }

    context "when the vacancy's job_advert is present" do
      context "when skills_and_experience is nil " do
        let(:params) { { skills_and_experience: nil } }
        let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher", job_advert: "Test") }

        it "is valid" do
          expect(subject.errors.added?(*error)).to be false
        end
      end

      context "when skills_and_experience exceeds the maxiumum words " do
        let(:params) { { skills_and_experience: Faker::Lorem.sentence(word_count: 151) } }
        let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher", job_advert: "Test") }

        it "is valid" do
          expect(subject.errors.added?(*error)).to be false
        end
      end
    end

    context "when school offer is not present" do
      let(:params) { { skills_and_experience: nil } }

      it "fails validation" do
        expect(subject.errors.added?(*error)).to be true
      end

      it "has the correct error message" do
        expect(subject.errors.messages[:skills_and_experience]).to include(I18n.t("about_the_role_errors.skills_and_experience.blank"))
      end
    end

    context "when job_advert ony contains bullet points" do
      let(:params) { { skills_and_experience: "<editor-content><ul><li><br></li></ul></editor-content>" } }

      it "fails validation" do
        expect(subject.errors.added?(*error)).to be true
      end

      it "has the correct error message" do
        expect(subject.errors.messages[:skills_and_experience]).to include(I18n.t("about_the_role_errors.skills_and_experience.blank"))
      end
    end

    context "when skills_and_experience is over 150 words" do
      let(:error) { %i[skills_and_experience length] }
      let(:params) { { skills_and_experience: Faker::Lorem.sentence(word_count: 151) } }

      it "fails validation" do
        expect(subject.errors.added?(*error)).to be true
      end

      it "has the correct error message" do
        expect(subject.errors.messages[:skills_and_experience]).to include(I18n.t("about_the_role_errors.skills_and_experience.length"))
      end
    end
  end

  describe "school_offer" do
    let(:error) { [:school_offer, :blank, { organisation: "school" }] }

    context "when the vacancy's about_school is present" do
      context "when school_offer is nil" do
        let(:params) { { school_offer: nil } }
        let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher", about_school: "Test") }

        it "is valid" do
          expect(subject.errors.added?(*error)).to be false
        end
      end

      context "when school_offer exceeds the maximum words" do
        let(:params) { { school_offer: Faker::Lorem.sentence(word_count: 151) } }
        let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher", about_school: "Test") }

        it "is valid" do
          expect(subject.errors.added?(*error)).to be false
        end
      end
    end

    context "when school offer is not present" do
      let(:params) { { school_offer: nil } }

      it "fails validation" do
        expect(subject.errors.added?(*error)).to be true
      end

      it "has the correct error message" do
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.blank", organisation: "school"))
      end
    end

    context "when job_advert ony contains bullet points" do
      let(:params) { { school_offer: "<editor-content><ul><li><br></li></ul></editor-content>" } }

      it "fails validation" do
        expect(subject.errors.added?(*error)).to be true
      end

      it "has the correct error message" do
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.blank", organisation: "school"))
      end
    end

    context "when school_offer is over 150 words" do
      let(:error) { [:school_offer, :length, { organisation: "School" }] }
      let(:params) { { school_offer: Faker::Lorem.sentence(word_count: 151) } }

      it "fails validation" do
        expect(subject.errors.added?(*error)).to be true
      end

      it "has the correct error message" do
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.length", organisation: "School"))
      end
    end
  end

  describe "safeguarding_information" do
    context "when safeguarding_information_provided is false" do
      before { allow(subject).to receive(:safeguarding_information_provided).and_return("false") }
      it { is_expected.not_to validate_presence_of(:safeguarding_information) }
    end

    context "when safeguarding_information_provided is true" do
      let(:error) { %i[safeguarding_information blank] }
      let(:params) { { safeguarding_information: safeguarding_information, safeguarding_information_provided: "true" } }

      context "when safeguarding_information has been provided" do
        let(:error) { %i[safeguarding_information blank] }
        let(:safeguarding_information) { Faker::Lorem.sentence(word_count: 99) }

        it "passes validation" do
          expect(subject.errors.added?(*error)).to be false
        end
      end

      context "when safeguarding_information has not been provided" do
        let(:error) { %i[safeguarding_information blank] }
        let(:safeguarding_information) { nil }

        it "fails validation" do
          expect(subject.errors.added?(*error)).to be true
        end
      end

      context "when either job_advert or about_school is present" do
        let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher", about_school: "Test") }
        let(:safeguarding_information) { nil }

        it "does not fail validation" do
          expect(subject.errors.added?(*error)).to be false
        end
      end

      context "when safeguarding_information is over 100 words" do
        let(:error) { %i[safeguarding_information length] }
        let(:params) { { safeguarding_information: Faker::Lorem.sentence(word_count: 101), safeguarding_information_provided: "true" } }

        it "fails validation" do
          expect(subject.errors.added?(*error)).to be true
        end

        it "has the correct error message" do
          expect(subject.errors.messages[:safeguarding_information]).to include(I18n.t("about_the_role_errors.safeguarding_information.length"))
        end
      end
    end
  end

  describe "further_details" do
    context "when further_details_provided is false" do
      before { allow(subject).to receive(:further_details_provided).and_return("false") }
      it { is_expected.not_to validate_presence_of(:further_details) }
    end

    context "when further_details_provided is true" do
      before { allow(subject).to receive(:further_details_provided).and_return("true") }

      it { is_expected.to validate_presence_of(:further_details) }

      context "when either job_advert or about_school is present" do
        let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher", about_school: "Test") }

        it { is_expected.not_to validate_presence_of(:further_details) }
      end

      context "when further_details is over 100 words" do
        let(:error) { %i[further_details length] }
        let(:params) { { further_details: Faker::Lorem.sentence(word_count: 101), further_details_provided: "true" } }

        it "fails validation" do
          expect(subject.errors.added?(*error)).to be true
        end

        it "has the correct error message" do
          expect(subject.errors.messages[:further_details]).to include(I18n.t("about_the_role_errors.further_details.length"))
        end
      end
    end
  end

  describe "job_advert" do
    context "when job_advert ony contains bullet points" do
      let(:error) { %i[job_advert blank] }
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher", job_advert: "Test") }
      let(:params) { { job_advert: "<editor-content><ul><li><br></li></ul></editor-content>" } }

      it "fails validation" do
        expect(subject.errors.added?(*error)).to be true
      end

      it "has the correct error message" do
        expect(subject.errors.messages[:job_advert]).to include(I18n.t("about_the_role_errors.job_advert.blank"))
      end
    end
  end
end
