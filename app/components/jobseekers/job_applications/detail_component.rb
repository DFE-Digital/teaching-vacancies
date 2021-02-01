class Jobseekers::JobApplications::DetailComponent < ViewComponent::Base
  attr_reader :detail, :counter, :info_to_display

  def initialize(detail:, detail_counter:, info_to_display:)
    @detail = detail
    @counter = detail_counter
    @info_to_display = info_to_display
  end
end
