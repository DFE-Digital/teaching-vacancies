require "rails_helper"

RSpec.describe "Jobseekers can complete a religious job application" do
  let(:jobseeker) { create(:jobseeker, jobseeker_profile: jobseeker_profile) }
  let(:jobseeker_profile) { create(:jobseeker_profile, :with_trn) }
  let(:organisation) { create(:school) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }
  let(:vacancy) { create(:vacancy, organisations: [organisation], religion_type: religion_type) }

  let(:referee_name) { Faker::Name.name }
  let(:referee_address) { Faker::Address.full_address }
  let(:referee_role) { "Pastor at #{Faker::Religion::Bible.location}" }
  let(:referee_email) { Faker::Internet.email(domain: "contoso.com") }
  let(:referee_phone) { Faker::PhoneNumber.phone_number }
  let(:place_of_worship_start_date) { Date.new(2021, 1, 1) }

  before { login_as(jobseeker, scope: :jobseeker) }
  after { logout }

  context "with a catholic vacancy" do
    let(:religion_type) { :catholic }

    before do
      fill_in_application_up_to_and_including_personal_statement
      click_on I18n.t("jobseekers.job_applications.build.catholic.step_title")
      choose "Yes, I've completed this section"
    end

    it "passes a11y", :a11y do
      #  https://github.com/alphagov/govuk-frontend/issues/979
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"
    end

    it "validates first religion step" do
      expect(page).to have_content(I18n.t("jobseekers.job_applications.build.catholic.preference_to_catholics"))
      validates_step_complete
      expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/religious_information_form.attributes.following_religion.inclusion"))
    end

    context "without a religion" do
      before do
        find("label[for='jobseekers-job-application-catholic-form-following-religion-false-field']").click
        click_on I18n.t("buttons.save_and_continue")
      end

      it "skips the religion details step" do
        expect(page).to have_current_path(jobseekers_job_application_apply_path(job_application))
        complete_from_references_page
      end
    end

    context "with a religion" do
      before do
        find("label[for='jobseekers-job-application-catholic-form-following-religion-true-field']").click
        choose "Yes, I've completed this section"
      end

      it "produces the correct errors" do
        validates_step_complete
        expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/religious_information_form.attributes.faith.blank"))
        expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/religious_information_form.attributes.religious_reference_type.inclusion"))
      end

      context "with a denomination" do
        before do
          fill_in I18n.t("helpers.label.jobseekers_job_application_catholic_form.faith"), with: "follower of #{Faker::Religion::Bible.character}"
          fill_in I18n.t("helpers.label.jobseekers_job_application_catholic_form.place_of_worship"), with: "#{Faker::Address.city} Church"
          fill_in "jobseekers_job_application_catholic_form[place_of_worship_start_date(3i)]", with: place_of_worship_start_date.day
          fill_in "jobseekers_job_application_catholic_form[place_of_worship_start_date(2i)]", with: place_of_worship_start_date.month
          fill_in "jobseekers_job_application_catholic_form[place_of_worship_start_date(1i)]", with: place_of_worship_start_date.year
        end

        context "with a referee" do
          before do
            find("label[for='jobseekers-job-application-catholic-form-religious-reference-type-religious-referee-field']").click
          end

          it "produces the correct error messages" do
            validates_step_complete
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/religious_information_form.attributes.religious_referee_name.blank"))
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/religious_information_form.attributes.religious_referee_role.blank"))
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/religious_information_form.attributes.religious_referee_address.blank"))
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/religious_information_form.attributes.religious_referee_email.blank"))
          end

          context "when on review page" do
            before do
              fill_in I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_name"), with: referee_name
              fill_in I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_address"), with: referee_address
              fill_in I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_role"), with: referee_role
              fill_in I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_email"), with: referee_email
              fill_in I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_referee_phone"), with: referee_phone

              choose "Yes, I've completed this section"
              click_on I18n.t("buttons.save_and_continue")
              complete_from_references_page
            end

            it "passes a11y", :a11y do
              expect(page).to be_axe_clean
            end

            it "has a correct change link" do
              expect(page).to have_link(href: jobseekers_job_application_build_path(job_application, :catholic))
            end

            it "shows the referee details" do
              expect(page).to have_content(I18n.t("jobseekers.job_applications.build.referees.heading"))

              expect(page).to have_content(referee_name)
              expect(page).to have_content(referee_address)
              expect(page).to have_content(referee_role)
              expect(page).to have_content(referee_email)
              expect(page).to have_content(referee_phone)
            end

            it "contains the entered information" do
              expect(job_application.reload).to have_attributes(religious_reference_type: "religious_referee")
              expect(page).to have_content(place_of_worship_start_date.to_fs(:day_month_year))
            end

            it "can submit application" do
              check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
              check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")
              click_on I18n.t("buttons.submit_application")
              click_on I18n.t("jobseekers.job_applications.post_submit.next_step.view_applications")
              expect(page).to have_content(vacancy.job_title)
            end
          end
        end

        context "with a baptism certificate" do
          before do
            choose I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_reference_type_options.baptism_certificate")
          end

          it "produces the correct errors" do
            validates_step_complete
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/catholic_form.attributes.baptism_certificate.blank"))
          end

          context "with an uploaded baptism cerificate" do
            before do
              page.attach_file("jobseekers-job-application-catholic-form-baptism-certificate-field", Rails.root.join("spec/fixtures/files/blank_baptism_cert.pdf"))

              allow_any_instance_of(FormFileValidator).to receive(:virus_free?).and_return(true)
              click_on I18n.t("buttons.save_and_continue")
            end

            it "allows the certificate to be uploaded" do
              expect(page).to have_content(I18n.t("jobseekers.job_applications.build.referees.heading"))
              complete_from_references_page
              expect(page).to have_content("blank_baptism_cert.pdf")
            end

            it "can submit application" do
              complete_from_references_page
              check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
              check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")
              click_on I18n.t("buttons.submit_application")
              click_on I18n.t("jobseekers.job_applications.post_submit.next_step.view_applications")
              expect(page).to have_content(vacancy.job_title)
            end
          end
        end

        context "with an address and date of baptism" do
          before do
            choose I18n.t("helpers.label.jobseekers_job_application_catholic_form.religious_reference_type_options.baptism_date")
          end

          let(:baptism_address) { Faker::Address.full_address }

          it "produces the correct errors" do
            validates_step_complete
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/catholic_form.attributes.baptism_address.blank"))
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/catholic_form.attributes.baptism_date.blank"))
          end

          it "allows jobseekers to specify a baptism address and date" do
            fill_in I18n.t("helpers.label.jobseekers_job_application_catholic_form.baptism_address"), with: baptism_address
            fill_in "Day", with: 7
            fill_in "Month", with: 3
            fill_in "Year", with: 2007
            click_on I18n.t("buttons.save_and_continue")
            expect(page).to have_content(I18n.t("jobseekers.job_applications.build.referees.heading"))
            complete_from_references_page

            expect(page).to have_content("07 March 2007")
            expect(page).to have_content(baptism_address)
          end
        end

        context "without a referee" do
          before do
            find("label[for='jobseekers-job-application-catholic-form-religious-reference-type-no-religious-referee-field']").click
          end

          it "allows jobseeker to not specify a religious referee" do
            click_on I18n.t("buttons.save_and_continue")
            expect(page).to have_content(I18n.t("jobseekers.job_applications.build.referees.heading"))
          end
        end
      end
    end
  end

  context "with other religion type vacancy" do
    let(:religion_type) { :other_religion }

    before do
      fill_in_application_up_to_and_including_personal_statement
      click_on I18n.t("jobseekers.job_applications.build.catholic.step_title")
      choose "Yes, I've completed this section"
    end

    it "validates ethos and aims step" do
      expect(page).to have_content(I18n.t("jobseekers.job_applications.build.non_catholic.preference_to_religious_applicants"))
      validates_step_complete
      expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/non_catholic_form.attributes.ethos_and_aims.blank"))
    end

    context "when on page 2" do
      before do
        fill_in I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.ethos_and_aims"), with: Faker::Lorem.sentence
      end

      it "passes a11y", :a11y do
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      it "show the correct error" do
        validates_step_complete
        expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/non_catholic_form.attributes.following_religion.inclusion"))
      end

      context "when completing following religion question" do
        before do
          find("label[for='jobseekers-job-application-non-catholic-form-following-religion-#{following_religion}-field']").click
        end

        context "when not following a religion" do
          let(:following_religion) { false }

          before do
            click_on I18n.t("buttons.save_and_continue")
            complete_from_references_page
          end

          it "completes the religious journey" do
            submit_application_from_review
            expect(page).to have_content(I18n.t("jobseekers.job_applications.post_submit.panel.title"))
          end

          it "has a correct change link" do
            expect(page).to have_link(href: jobseekers_job_application_build_path(job_application, :non_catholic))
          end
        end

        context "when following a religion" do
          let(:following_religion) { true }

          it "displays the non catholic details form" do
            expect(page).to have_content(I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.faith"))
          end

          it "errors correctly" do
            validates_step_complete
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/non_catholic_form.attributes.faith.blank"))
            expect(page).to have_content(I18n.t("activemodel.errors.models.jobseekers/job_application/non_catholic_form.attributes.religious_reference_type.inclusion"))
          end

          context "with a faith" do
            before do
              fill_in I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.faith"), with: "follower of #{Faker::Religion::Bible.character}"
              fill_in I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.place_of_worship"), with: "#{Faker::Address.city} Church"
            end

            context "without a referee" do
              before do
                find("label[for='jobseekers-job-application-non-catholic-form-religious-reference-type-no-religious-referee-field']").click
              end

              it "completes the journey" do
                click_on I18n.t("buttons.save_and_continue")
                expect(page).to have_content(I18n.t("jobseekers.job_applications.build.referees.heading"))
                complete_from_references_page
                submit_application_from_review
                expect(page).to have_content(I18n.t("jobseekers.job_applications.post_submit.panel.title"))
              end
            end

            context "when entering a referee" do
              before do
                find("label[for='jobseekers-job-application-non-catholic-form-religious-reference-type-religious-referee-field']").click
              end

              it "errors when not entered" do
                validates_step_complete
              end

              it "can complete the journey" do
                fill_in I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.religious_referee_name"), with: referee_name
                fill_in I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.religious_referee_address"), with: referee_address
                fill_in I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.religious_referee_role"), with: referee_role
                fill_in I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.religious_referee_email"), with: referee_email
                fill_in I18n.t("helpers.label.jobseekers_job_application_non_catholic_form.religious_referee_phone"), with: referee_phone
                click_on I18n.t("buttons.save_and_continue")
                complete_from_references_page
                submit_application_from_review
                expect(page).to have_content(I18n.t("jobseekers.job_applications.post_submit.panel.title"))
              end
            end
          end
        end
      end
    end
  end

  def fill_in_application_up_to_and_including_personal_statement
    visit jobseekers_job_application_build_path(job_application, :personal_details)
    fill_in_personal_details
    click_on I18n.t("buttons.save_and_continue")

    click_on(I18n.t("jobseekers.job_applications.build.professional_status.heading"))
    fill_in_professional_status
    click_on I18n.t("buttons.save_and_continue")

    click_on(I18n.t("jobseekers.job_applications.build.qualifications.heading"))
    choose I18n.t("helpers.label.jobseekers_job_application_qualifications_form.qualifications_section_completed_options.true")
    click_on I18n.t("buttons.save_and_continue")

    click_on(I18n.t("jobseekers.job_applications.build.qualifications.heading"))
    click_on I18n.t("buttons.add_qualification")

    select_qualification_category("Undergraduate degree")
    fill_in_undergraduate_degree
    click_on I18n.t("buttons.save_qualification.one")
    click_on I18n.t("buttons.save_and_continue")

    click_on(I18n.t("jobseekers.job_applications.build.training_and_cpds.heading"))
    click_on "Add training"
    fill_in_training_and_cpds
    click_on "Save and continue"
    choose "Yes, I've completed this section"
    click_on "Save and continue"

    click_on(I18n.t("jobseekers.job_applications.build.professional_body_memberships.list_heading"))
    click_on "Add membership"
    fill_in_professional_body_membership
    click_on "Save and continue"
    choose "Yes, I've completed this section"
    click_on "Save and continue"

    click_on(I18n.t("jobseekers.job_applications.build.employment_history.heading"))
    click_on I18n.t("buttons.add_work_history")
    fill_in_employment_history
    click_on I18n.t("buttons.save_employment")
    click_on I18n.t("buttons.add_reason_for_break")
    fill_in_break_in_employment(end_year: Time.zone.today.year.to_s, end_month: Time.zone.today.month.to_s.rjust(2, "0"))
    click_on I18n.t("buttons.continue")
    choose I18n.t("helpers.label.jobseekers_job_application_employment_history_form.employment_history_section_completed_options.true")
    click_on I18n.t("buttons.save_and_continue")

    click_on(I18n.t("jobseekers.job_applications.build.personal_statement.heading"))
    fill_in_personal_statement
    click_on I18n.t("buttons.save_and_continue")
  end

  def complete_from_references_page
    click_on(I18n.t("jobseekers.job_applications.build.referees.heading"))
    click_on I18n.t("buttons.add_reference")
    fill_in_referee
    click_on I18n.t("buttons.save_reference")
    click_on I18n.t("buttons.add_another_reference")
    fill_in_referee
    click_on I18n.t("buttons.save_reference")
    choose I18n.t("helpers.label.jobseekers_job_application_referees_form.referees_section_completed_options.true")
    click_on I18n.t("buttons.save_and_continue")

    click_on(I18n.t("jobseekers.job_applications.build.equal_opportunities.heading"))
    fill_in_equal_opportunities
    click_on I18n.t("buttons.save_and_continue")

    click_on(I18n.t("jobseekers.job_applications.build.ask_for_support.heading"))
    fill_in_ask_for_support
    click_on I18n.t("buttons.save_and_continue")

    click_on(I18n.t("jobseekers.job_applications.build.declarations.heading"))
    fill_in_declarations
    click_on I18n.t("buttons.save_and_continue")
    click_on "Review application"
  end

  def submit_application_from_review
    check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
    check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")
    click_on I18n.t("buttons.submit_application")
  end
end
