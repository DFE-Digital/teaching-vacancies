# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        class JobApplicationSection < SitePrism::Section
          def self.selector(index)
            %(td:nth-child(#{index}))
          end

          element :checkbox, ".govuk-checkboxes__input", visible: false
          element :name, ".name"
          element :name_link, ".name a"
          element :email, ".email_address"
          element :status, ".status"

          STATUS_MAPPING = {
            "unread" => "submitted",
            "not considering" => "unsuccessful",
          }.freeze

          def mapped_status
            STATUS_MAPPING.fetch(status.text) { it }
          end
        end

        class JobApplicationTabPanelSection < Sections::TabsSection
          sections :job_applications, JobApplicationSection, ".govuk-table__body .govuk-table__row"
          sections :declined_job_applications, JobApplicationSection, ".application-declined.govuk-table__row"

          element :heading, "h3"
          element :btn_download, '.govuk-button[value="download"]'
          element :btn_update_status, '.govuk-button[value="update_status"]'
          element :btn_decline, '.govuk-button[value="declined"]'
          element :btn_copy_emails, '.govuk-button[value="emails"]'
          element :btn_export, '.govuk-button[value="export"]'
        end

        class JobApplicationsPage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications"

          element :job_title, "h1"
          elements :tabs, ".govuk-tabs__tab"
          section :nav, Sections::NavSection, ".job-applications-nav"
          section :tab_panel, JobApplicationTabPanelSection, ".govuk-tabs__panel"

          def get_tab(tab_id)
            tabs.detect { |tab| tab["id"] == tab_id.to_s }
          end

          def select_tab(tab_id)
            get_tab(tab_id).click
          end

          def selected_tab
            tabs.detect { |tab| tab["aria-selected"] == "true" }
          end

          def update_status(*selection)
            selection.each { select_candidate(it) }
            tab_panel.btn_update_status.click

            tag_page = PageObjects::Pages::Publisher::Ats::TagPage.new
            if tag_page.displayed?
              yield tag_page
            else
              raise "Tag page not displayed"
            end
          end

          def decline_offer(*selection)
            selection.each { select_candidate(it) }
            tab_panel.btn_decline.click

            job_decline_date_page = PageObjects::Pages::Publisher::Ats::JobDeclineDatePage.new
            if job_decline_date_page.displayed?
              yield job_decline_date_page
            else
              raise "decline offer date page not displayed"
            end
          end

          def candidate(job_application)
            tab_panel.job_applications.detect { it.name.text == job_application.name }
          end

          def select_candidate(job_application)
            job_application = candidate(job_application)
            job_application.checkbox.click
          end
        end
      end
    end
  end
end
