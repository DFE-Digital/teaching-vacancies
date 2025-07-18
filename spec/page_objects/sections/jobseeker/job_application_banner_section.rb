module Sections
  module Jobseeker
    class JobApplicationBannerSection < SitePrism::Section
      element :header, "h1"
      element :tag, ".status-tag"
      element :delete_btn, ".delete-application"
      element :withdraw_btn, ".withdraw-application"
      element :download_btn, ".print-application"
      element :view_link, ".view-listing-link"
    end
  end
end
