module Sections
  module Jobseeker
    class JobApplicationTaskSection < SitePrism::Section
      element :name, ".govuk-task-list__name-and-hint a"
      element :status, ".govuk-task-list__status"
    end
  end
end
