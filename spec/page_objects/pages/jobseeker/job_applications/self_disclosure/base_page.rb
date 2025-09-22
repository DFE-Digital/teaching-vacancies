# frozen_string_literal: true

module PageObjects
  module Pages
    module Jobseeker
      module JobApplications
        module SelfDisclosure
          class BasePage < CommonPage
            def self.selector(page, field)
              %(input[name="jobseekers_job_applications_self_disclosure_#{page}_form[#{field}]"])
            end

            def submit_form
              click_on "Save and continue"
            end

            def fill_in_and_submit_form(model)
              # text inputs
              self.class.mapped_items[:element].each do |field|
                public_send(field).set(model.public_send(field))
              end

              # radio buttons
              self.class.mapped_items[:elements].each do |field|
                value = model.public_send(field).to_s
                case value
                when "true"
                  public_send(field, visible: false).first.set(true)
                when "false"
                  public_send(field, visible: false).last.set(true)
                end
              end

              # date fields
              self.class.mapped_items[:section].each do |field|
                group = public_send(field)
                model_date = model.public_send(field)

                group.day.set(model_date&.day)
                group.month.set(model_date&.month)
                group.year.set(model_date&.year)
              end

              submit_form
            end
          end
        end
      end
    end
  end
end
