require "rails_helper"

RSpec.describe Publishers::JobListing::AboutTheRoleForm, type: :model do
  subject do
    described_class.load_from_params(vacancy.slice(*class_fields)
                                                    .merge(needs_qts_status: false, ect_suitable: false)
                                                    .merge(params), vacancy, current_publisher: nil)
  end

  let(:job_roles) { %w[teacher] }
  let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles:) }
  let(:organisation) { build_stubbed(:school) }
  let(:params) { {} }
  let(:class_fields) { described_class.fields - %i[needs_qts_status ect_suitable] }

  describe "load_from_model" do
    let(:form) { described_class.load_from_model(vacancy, current_publisher: nil) }

    context "with ect_status suitable for non-teacher" do
      let(:vacancy) { build_stubbed(:vacancy, ect_status: :suitable_for_non_teachers) }

      it "doesnt require QTS" do
        expect(form.needs_qts_status).to be(false)
        expect(form.ect_suitable).to be(true)
      end
    end

    context "with ect_status suitable" do
      let(:vacancy) { build_stubbed(:vacancy, ect_status: :ect_suitable) }

      it "doesnt require QTS" do
        expect(form.needs_qts_status).to be(true)
        expect(form.ect_suitable).to be(true)
      end
    end

    context "without ect_status" do
      let(:vacancy) { build_stubbed(:vacancy, ect_status: nil) }

      it "doesnt require QTS" do
        expect(form.ect_suitable).to be_nil
        expect(form.needs_qts_status).to be_nil
      end
    end

    context "with ect_status non suitable" do
      let(:vacancy) { build_stubbed(:vacancy, ect_status: :ect_unsuitable) }

      it "doesnt require QTS" do
        expect(form.needs_qts_status).to be(true)
        expect(form.ect_suitable).to be(false)
      end
    end
  end

  describe "#params_to_save" do
    context "without QTS" do
      let(:params) { { needs_qts_status: false } }

      it "allows non-teachers" do
        expect(subject.params_to_save.fetch(:ect_status)).to eq(:suitable_for_non_teachers)
      end
    end

    context "with QTS but suitable" do
      let(:params) { { needs_qts_status: true, ect_suitable: true } }

      it "is suitable" do
        expect(subject.params_to_save.fetch(:ect_status)).to eq(:ect_suitable)
      end
    end

    context "with QTS unsuitable" do
      let(:params) { { needs_qts_status: true, ect_suitable: false } }

      it "is unsuitable" do
        expect(subject.params_to_save.fetch(:ect_status)).to eq(:ect_unsuitable)
      end
    end

    it "contains all the fields" do
      expect(subject.params_to_save.keys).to match_array(class_fields + [:ect_status])
    end
  end

  describe "skills_and_experience" do
    let(:error) { %i[skills_and_experience blank] }

    context "when skills_and_experience exceeds the maximum words " do
      let(:params) { {} }
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles: ["teacher"]) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when school offer is not present" do
      let(:params) { { skills_and_experience: nil } }

      it "has the correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:skills_and_experience]).to include(I18n.t("about_the_role_errors.skills_and_experience.blank"))
      end
    end

    context "when job_advert ony contains bullet points" do
      let(:params) { { skills_and_experience: "<editor-content><ul><li><br></li></ul></editor-content>" } }

      it "has the correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:skills_and_experience]).to include(I18n.t("about_the_role_errors.skills_and_experience.blank"))
      end
    end
  end

  describe "organisation_type" do
    let(:params) { { school_offer: nil } }

    context "when the vacancy is for a trust central office" do
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles:).tap { |v| allow(v).to receive(:central_office?).and_return(true) } }

      it "uses 'trust' in the school_offer error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.blank", organisation: "trust"))
      end
    end

    context "when the vacancy is for an FE college" do
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles:).tap { |v| allow(v).to receive(:for_an_fe_college?).and_return(true) } }

      it "uses 'college' in the school_offer error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.blank", organisation: "college"))
      end
    end

    context "when the vacancy is for multip123:1le organisations" do
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_roles:).tap { |v| allow(v).to receive(:for_multiple_organisations?).and_return(true) } }

      it "uses 'schools' in the school_offer error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.blank", organisation: "schools"))
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

      it "has the correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.blank", organisation: "school"))
      end
    end

    context "when job_advert ony contains bullet points" do
      let(:params) { { school_offer: "<editor-content><ul><li><br></li></ul></editor-content>" } }

      it "has the correct error message" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.blank", organisation: "school"))
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
        expect(subject).not_to be_valid
        expect(subject.errors[:flexi_working]).to include("Enter flexible working details")
      end
    end

    context "when flexi_working_details_provided is 'true' and flexi_working is provided" do
      let(:params) { { flexi_working_details_provided: "true", flexi_working: "Some flexible working details" } }

      it "passes validation" do
        expect(subject).to be_valid
      end
    end

    context "when flexi_working_details_provided is 'false'" do
      let(:params) { { flexi_working_details_provided: "false", flexi_working: nil } }

      it "passes validation even if flexi_working is blank" do
        expect(subject).to be_valid
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
        expect(subject).not_to be_valid
        expect(subject.errors[:flexi_working_details_provided].blank?).to be false
      end
    end
  end
end
