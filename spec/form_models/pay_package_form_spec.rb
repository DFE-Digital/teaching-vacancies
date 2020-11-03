require "rails_helper"

RSpec.describe PayPackageForm, type: :model do
  context "validations" do
    describe "#salary" do
      let(:pay_package) { PayPackageForm.new(salary: salary) }

      context "when salary is blank" do
        let(:salary) { nil }

        it "requests an entry in the field" do
          expect(pay_package.valid?).to be false
          expect(pay_package.errors.messages[:salary]).to include(
            I18n.t("activemodel.errors.models.pay_package_form.attributes.salary.blank"),
          )
        end
      end

      context "when salary is too long" do
        let(:salary) { "Salary" * 100 }

        it "validates max length" do
          expect(pay_package.valid?).to be false
          expect(pay_package.errors.messages[:salary]).to include(
            I18n.t("activemodel.errors.models.pay_package_form.attributes.salary.too_long", count: 256),
          )
        end
      end

      context "when salary contains HTML tags" do
        let(:salary) { "Salary with <p>tags</p" }

        it "validates presence of HTML tags" do
          expect(pay_package.valid?).to be false
          expect(pay_package.errors.messages[:salary]).to include(
            I18n.t("activemodel.errors.models.pay_package_form.attributes.salary.invalid_characters"),
          )
        end
      end

      context "when salary does not contain HTML tags" do
        context "salary contains &" do
          let(:salary) { "Pay scale & another pay scale" }

          it "does not validate presence of HTML tags" do
            expect(pay_package.errors.messages[:salary]).to_not include(
              I18n.t("activemodel.errors.models.pay_package_form.attributes.salary.invalid_characters"),
            )
          end
        end
      end
    end
  end
end
