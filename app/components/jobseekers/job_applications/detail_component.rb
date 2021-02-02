class Jobseekers::JobApplications::DetailComponent < ViewComponent::Base
  attr_reader :detail, :counter, :info_to_display

  def initialize(detail:, detail_counter:, info_to_display:)
    @detail = detail
    @counter = detail_counter
    @info_to_display = info_to_display
  end

  def date_detail(attribute)
    Date.new(detail.data["#{attribute}(1i)"].to_i, detail.data["#{attribute}(2i)"].to_i, detail.data["#{attribute}(3i)"].to_i)
  rescue Date::Error
    nil
  end
end
