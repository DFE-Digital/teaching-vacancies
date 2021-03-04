class Jobseekers::JobApplications::DetailComponent < ViewComponent::Base
  attr_reader :detail, :title_attribute, :info_to_display

  def initialize(detail:, title_attribute:, info_to_display:)
    @detail = detail
    @title_attribute = title_attribute
    @info_to_display = info_to_display
  end

  def date_detail(attribute)
    Date.new(detail.data["#{attribute}(1i)"].to_i, detail.data["#{attribute}(2i)"].to_i, detail.data["#{attribute}(3i)"].to_i)
  rescue Date::Error
    nil
  end
end
