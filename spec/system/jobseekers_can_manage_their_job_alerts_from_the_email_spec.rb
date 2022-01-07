require "rails_helper"

RSpec.describe "Jobseekers can manage their job alerts from the email" do
  let(:jobseeker_signed_in?) { false }
  let(:jobseeker) { build_stubbed(:jobseeker) }

  let(:search_criteria) { { keyword: "Maths", location: "London" } }
  let(:frequency) { :daily }
  let(:subscription) { create(:subscription, email: jobseeker.email, frequency: frequency, search_criteria: search_criteria) }

  before do
    login_as(jobseeker, scope: :jobseeker) if jobseeker_signed_in?
    visit edit_subscription_path(token)
  end

  context "with the correct token" do
    let(:token) { subscription.token }

    describe "job alert confirmation page" do
      let(:keyword) { "English" }
      let(:location) { "Radley" }

      before do
        update_subscription_fields
        click_on I18n.t("buttons.update_alert")
      end

      context "when jobseeker has an account" do
        let!(:jobseeker) { create(:jobseeker) }

        context "when jobseeker is signed in" do
          let(:jobseeker_signed_in?) { true }

          it "redirects to job alerts dashboard" do
            expect(current_path).to eq(jobseekers_subscriptions_path)
          end
        end

        context "when jobseeker is signed out" do
          it "renders a sign in prompt form that redirects to job alerts dashboard" do
            within "div[data-account-prompt='sign-in']" do
              expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_in"))
              fill_in "Password", with: jobseeker.password
              within(".edit_jobseeker") do
                click_on I18n.t("buttons.sign_in")
              end
            end
            expect(current_path).to eq(jobseekers_subscriptions_path)
          end

          it "renders a sign in prompt form that redirects to sign in page on error then redirects to job alerts dashboard" do
            within "div[data-account-prompt='sign-in']" do
              expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_in"))
              click_on I18n.t("buttons.sign_in")
            end
            sign_in_jobseeker
            expect(current_path).to eq(jobseekers_subscriptions_path)
          end
        end
      end

      context "when jobseeker does not have an account" do
        it "renders a create an account prompt form that redirects to job alerts dashboard" do
          within "div[data-account-prompt='sign-up']" do
            expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_up"))
            fill_in "Password", with: jobseeker.password
            click_on I18n.t("buttons.create_account")
          end
          confirm_email_address
          expect(current_path).to eq(jobseekers_subscriptions_path)
        end

        it "renders a create an account prompt form that redirects to sign up page on error then redirects to job alerts dashboard" do
          within "div[data-account-prompt='sign-up']" do
            expect(page).to have_content(I18n.t("subscriptions.jobseeker_account_prompt.heading.sign_up"))
            click_on I18n.t("buttons.create_account")
          end
          sign_up_jobseeker
          confirm_email_address
          expect(current_path).to eq(jobseekers_subscriptions_path)
        end
      end
    end

    it "shows the page title" do
      expect(page).to have_content(I18n.t("subscriptions.edit.title"))
    end

    context "when updating the subscription" do
      let(:keyword) { "English" }
      let(:location) { "Radley" }
      let(:frequency) { :weekly }

      before do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(Jobseekers::SubscriptionMailer).to receive(:update) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)

        update_subscription_fields
        click_on I18n.t("buttons.update_alert")
      end

      it "shows the confirmation page" do
        expect(page).to have_content(I18n.t("subscriptions.confirm.header.update"))
      end

      it "updates the subscription" do
        subscription.reload
        expect(subscription.email).to eq(jobseeker.email)
        expect(subscription.frequency).to eq("weekly")
        expect(subscription.search_criteria["keyword"]).to eq("English")
        expect(subscription.search_criteria["location"]).to eq("Radley")
      end
    end

    context "when updating with no criteria" do
      let(:keyword) { "" }
      let(:location) { "" }

      before do
        update_subscription_fields
        click_on I18n.t("buttons.update_alert")
      end

      it "does not update the subscription" do
        subscription.reload
        expect(subscription.email).to eq(jobseeker.email)
        expect(subscription.frequency).to eq("daily")
        expect(subscription.search_criteria["keyword"]).to eq("Maths")
        expect(subscription.search_criteria["location"]).to eq("London")
      end
    end
  end

  context "with the incorrect token" do
    let(:token) { subscription.id }

    it "returns not found" do
      expect(page.status_code).to eq(404)
    end
  end

  context "with an old token" do
    let(:token) { subscription.token }

    scenario "still returns 200" do
      travel 3.days do
        expect(page.status_code).to eq(200)
      end
    end
  end

  def update_subscription_fields
    fill_in "jobseekers-subscription-form-keyword-field", with: keyword
    fill_in "jobseekers-subscription-form-location-field", with: location
    choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.#{frequency}")
  end
end
