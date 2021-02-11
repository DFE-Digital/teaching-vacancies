module PageObjects
  module Search
    class Filters < SitePrism::Section
      element :keyword, "#keyword-field"
      element :location, "#location-field"
      element :teacher, "#job-roles-teacher-field"
      element :leadership, "#job-roles-leadership-field"
      element :sen_specialist, "#job-roles-sen-specialist-field"
      element :nqt_suitable, "#job-roles-nqt-suitable-field"
      element :primary, "#phases-primary-field"
      element :middle, "#phases-middle-field"
      element :secondary, "#phases-secondary-field"
      element :sixteen_to_nineteen, "#phases-16-19-field"
      element :full_time, "#working-patterns-full-time-field"
      element :part_time, "#working-patterns-part-time-field"
      element :job_share, "#working-patterns-job-share-field"

      section :selected, ".moj-filter__selected" do
        elements :tags, ".moj-filter__tag"
      end

      def toggle_visibility
        find(".govuk-details").click
      end
    end
  end
end
