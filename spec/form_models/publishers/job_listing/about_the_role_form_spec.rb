require "rails_helper"

RSpec.describe Publishers::JobListing::AboutTheRoleForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:job_roles) { %w[teacher] }
  let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles:) }
  let(:organisation) { build_stubbed(:school) }
  let(:params) { {} }

  before { subject.valid? }

  context "when vacancy job roles contains `teacher`" do
    let(:job_roles) { %w[teacher] }

    it { is_expected.to validate_inclusion_of(:ect_status).in_array(DraftVacancy.ect_statuses.keys) }
  end

  context "when vacancy job roles does not contain `teacher`" do
    let(:job_roles) { nil }

    it { is_expected.not_to validate_inclusion_of(:ect_status).in_array(DraftVacancy.ect_statuses.keys) }
  end

  describe "skills_and_experience" do
    let(:error) { %i[skills_and_experience blank] }

    context "when skills_and_experience exceeds the maximum words " do
      let(:params) { { skills_and_experience: Faker::Lorem.sentence(word_count: 151) } }
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles: ["teacher"]) }

      it "is valid" do
        expect(subject.errors.added?(*error)).to be false
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
  end

  describe "school_offer" do
    let(:error) { [:school_offer, :blank, { organisation: "school" }] }

    context "when school_offer exceeds the maximum words" do
      let(:params) { { school_offer: Faker::Lorem.sentence(word_count: 151) } }
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles: ["teacher"]) }

      it "is valid" do
        expect(subject.errors.added?(*error)).to be false
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
  end

  describe "safeguarding_information" do
    context "when safeguarding_information is already present on the vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles: ["teacher"], safeguarding_information: "safeguarding") }

      context "when safeguarding_information_provided is false" do
        let(:error) { %i[safeguarding_information blank] }

        let(:params) { { safeguarding_information_provided: "false" } }

        it "passes validation" do
          expect(subject.errors.added?(*error)).to be false
        end
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

    context "when safeguarding_information is not already present on the vacancy" do
      let(:params) { { safeguarding_information: nil, safeguarding_information_provided: nil } }
      let(:presence_error) { %i[safeguarding_information blank] }
      let(:length_error) { %i[safeguarding_information length] }

      it "passes validation" do
        expect(subject.errors.added?(*presence_error)).to be false
        expect(subject.errors.added?(*length_error)).to be false
      end
    end
  end

  describe "further_details" do
    context "when further_details_provided is false" do
      let(:params) { { further_details_provided: "false" } }

      it { is_expected.not_to validate_presence_of(:further_details) }
    end

    context "when further_details_provided is true" do
      let(:params) { { further_details_provided: "true" } }

      it { is_expected.to validate_presence_of(:further_details) }
    end
  end

  describe "flexi_working" do
    let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles: ["teacher"]) }

    context "when flexi working is blank except for html tags" do
      let(:params) { { flexi_working: "<p><br></p>" } }

      it "sets flexi_working as nil in params_to_save" do
        expect(subject.params_to_save[:flexi_working]).to be_nil
      end
    end

    context "when flexi working has text and html tags" do
      let(:params) { { flexi_working: "<p>hello<br> world</p>" } }

      it "params_to_save includes flexi_working value" do
        expect(subject.params_to_save[:flexi_working]).to eq "<p>hello<br> world</p>"
      end
    end

    context "when flexi_working_details_provided is 'true' and flexi_working is blank" do
      let(:params) { { flexi_working_details_provided: "true", flexi_working: nil } }

      it "fails validation" do
        expect(subject.errors[:flexi_working]).to include("Enter flexible working details")
      end
    end

    context "when flexi_working_details_provided is 'true' and flexi_working is provided" do
      let(:params) { { flexi_working_details_provided: "true", flexi_working: "Some flexible working details" } }

      it "passes validation" do
        expect(subject.errors[:flexi_working_details_provided].blank?).to be true
      end
    end

    context "when flexi_working_details_provided is 'false'" do
      let(:params) { { flexi_working_details_provided: "false", flexi_working: nil } }

      it "passes validation even if flexi_working is blank" do
        expect(subject.errors[:flexi_working_details_provided].blank?).to be true
      end
    end
  end

  describe "flexi_working_details_provided" do
    let(:error) { %i[flexi_working_details_provided inclusion] }

    context "when flexi_working_details_provided is true" do
      let(:params) { { flexi_working_details_provided: true } }

      it "does not raise errors" do
        expect(subject.errors[:flexi_working_details_provided].blank?).to be true
      end
    end

    context "when flexi_working_details_provided is false" do
      let(:params) { { flexi_working_details_provided: false } }

      it "raises errors" do
        expect(subject.errors[:flexi_working_details_provided].blank?).to be true
      end
    end

    context "when flexi_working_details_provided is nil" do
      let(:params) { { flexi_working_details_provided: nil } }

      it "raises errors" do
        expect(subject.errors[:flexi_working_details_provided].blank?).to be false
      end
    end
  end
end
