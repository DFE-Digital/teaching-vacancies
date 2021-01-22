require "rails_helper"

RSpec.describe Publishers::JobListing::PayPackageForm, type: :model do
  subject { described_class.new(params) }

  context "validations" do
    describe "#salary" do
      context "when salary is blank" do
        let(:params) { { salary: "" } }

        it "requests an entry in the field" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:salary]).to include(I18n.t("pay_package_errors.salary.blank"))
        end
      end

      context "when salary is too long" do
        let(:params) { { salary: "Too long" * 100 } }

        it "validates max length" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:salary]).to include(I18n.t("pay_package_errors.salary.too_long", count: 256))
        end
      end

      context "when salary contains HTML tags" do
        let(:params) { { salary: "Salary with <p>tags</p" } }

        it "validates presence of HTML tags" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:salary]).to include(I18n.t("pay_package_errors.salary.invalid_characters"))
        end
      end

      context "when salary does not contain HTML tags" do
        context "salary contains &" do
          let(:params) { { salary: "Pay scale &amp; another pay scale" } }

          it "does not validate presence of HTML tags" do
            expect(subject.valid?).to be true
            expect(subject.errors.messages[:salary]).to_not include(I18n.t("pay_package_errors.salary.invalid_characters"))
          end
        end
      end
    end
  end
end
