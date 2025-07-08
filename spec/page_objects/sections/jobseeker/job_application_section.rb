module Sections
  module Jobseeker
    class JobApplicationSection < SitePrism::Section
      element :header, ".card-component__header a"
      element :tag, ".card-component__action .govuk-tag"
    end
  end
end
